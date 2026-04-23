import "server-only";

import type {
  AdminProfileRecord,
  AdminRecord,
  AdminRoleRecord,
  AdminSession,
  AuthMeResponse,
  DashboardPayload,
  IssueRefundResponse,
  IntegrationHealthRecord,
  LoginResponse,
  OrderStatus,
  ResourceListResponse,
  ResourceMutationResponse,
  UpdateOrderStatusResponse,
} from "@/lib/api/types";

const DEFAULT_API_BASE_URL = "http://localhost:3000";

type QueryValue = string | number | boolean | null | undefined;

type ApiRequestOptions = {
  method?: "GET" | "POST" | "PATCH" | "DELETE";
  token?: string;
  body?: unknown;
  query?: ResourceQuery;
};

type ResourceQuery = Record<string, QueryValue>;

export class ApiClientError extends Error {
  constructor(
    message: string,
    public readonly status: number,
    public readonly code?: string
  ) {
    super(message);
  }
}

function getApiBaseUrl() {
  // Prefer an explicit full URL when one is configured. Render Blueprints
  // cannot interpolate "http://" with a referenced host:port, so production
  // deploys can instead provide the internal hostport and let the admin app
  // derive the private-network base URL itself.
  if (process.env.BIZRUSH_API_BASE_URL) {
    return process.env.BIZRUSH_API_BASE_URL;
  }

  if (process.env.BIZRUSH_API_HOSTPORT) {
    return `http://${process.env.BIZRUSH_API_HOSTPORT}`;
  }

  return DEFAULT_API_BASE_URL;
}

function buildUrl(path: string, query?: ResourceQuery) {
  const url = new URL(path, getApiBaseUrl());

  if (!query) {
    return url;
  }

  for (const [key, value] of Object.entries(query)) {
    if (value === undefined || value === null || value === "") {
      continue;
    }

    url.searchParams.set(key, String(value));
  }

  return url;
}

async function parseError(response: Response) {
  try {
    const payload = (await response.json()) as { error?: string; message?: string };
    return new ApiClientError(
      payload.message ?? "The API request failed.",
      response.status,
      payload.error
    );
  } catch {
    return new ApiClientError("The API request failed.", response.status);
  }
}

async function requestJson<T>(path: string, options: ApiRequestOptions = {}) {
  const response = await fetch(buildUrl(path, options.query), {
    method: options.method ?? "GET",
    cache: "no-store",
    headers: {
      ...(options.body === undefined ? {} : { "content-type": "application/json" }),
      ...(options.token ? { authorization: `Bearer ${options.token}` } : {}),
    },
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
  });

  if (!response.ok) {
    throw await parseError(response);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export async function loginAdmin(email: string, password: string) {
  return requestJson<LoginResponse>("/v1/auth/login", {
    method: "POST",
    body: {
      role: "admin",
      email,
      password,
    },
  });
}

export async function logoutAdmin(token: string) {
  return requestJson<void>("/v1/auth/logout", {
    method: "POST",
    token,
  });
}

export async function listResource<T>(resourcePath: string, token: string, query?: ResourceQuery) {
  return requestJson<ResourceListResponse<T>>(`/v1/${resourcePath}`, {
    token,
    query,
  });
}

export async function getResource<T>(resourcePath: string, id: string, token: string) {
  return requestJson<ResourceMutationResponse<T>>(`/v1/${resourcePath}/${id}`, {
    token,
  });
}

export async function createResource<T>(
  resourcePath: string,
  token: string,
  body: Record<string, unknown>
) {
  return requestJson<ResourceMutationResponse<T>>(`/v1/${resourcePath}`, {
    method: "POST",
    token,
    body,
  });
}

export async function updateResource<T>(
  resourcePath: string,
  id: string,
  token: string,
  body: Record<string, unknown>
) {
  return requestJson<ResourceMutationResponse<T>>(`/v1/${resourcePath}/${id}`, {
    method: "PATCH",
    token,
    body,
  });
}

export async function deleteResource(resourcePath: string, id: string, token: string) {
  return requestJson<void>(`/v1/${resourcePath}/${id}`, {
    method: "DELETE",
    token,
  });
}

export async function getDashboard(token: string) {
  return requestJson<DashboardPayload>("/v1/admin/dashboard", {
    token,
  });
}

export async function updateOrderStatus(
  token: string,
  orderId: string,
  status: OrderStatus,
  note?: string
) {
  return requestJson<UpdateOrderStatusResponse>(`/v1/admin/orders/${orderId}/status`, {
    method: "POST",
    token,
    body: {
      status,
      ...(note ? { note } : {}),
    },
  });
}

export async function issueRefund(
  token: string,
  orderId: string,
  amountCents: number,
  reason: string
) {
  return requestJson<IssueRefundResponse>(`/v1/admin/orders/${orderId}/refund`, {
    method: "POST",
    token,
    body: {
      amountCents,
      reason,
    },
  });
}

export async function getAdminSession(token: string): Promise<AdminSession | null> {
  let me: AuthMeResponse;

  try {
    me = await requestJson<AuthMeResponse>("/v1/auth/me", {
      token,
    });
  } catch (error) {
    if (error instanceof ApiClientError && (error.status === 401 || error.status === 403)) {
      return null;
    }

    throw error;
  }

  if (me.principal.role !== "admin") {
    return null;
  }

  const adminId = me.principal.userId;
  const admin = await getResource<AdminRecord>("admins", adminId, token);
  const adminProfiles = await listResource<AdminProfileRecord>("admin-profiles", token, {
    admin_id: adminId,
    limit: 1,
    offset: 0,
  });
  const profile = adminProfiles.data[0];

  let role: AdminRoleRecord | null = null;
  if (profile?.role_id) {
    const roleResponse = await getResource<AdminRoleRecord>("admin-roles", profile.role_id, token);
    role = roleResponse.data;
  }

  if (!admin.data.email) {
    return null;
  }

  return {
    id: admin.data.admin_id,
    email: admin.data.email,
    role: "admin",
    fullName: admin.data.full_name ?? undefined,
    title: profile?.title ?? role?.name ?? undefined,
  };
}

export async function listIntegrations(token: string) {
  return listResource<IntegrationHealthRecord>("integration-health", token, {
    limit: 50,
    offset: 0,
  });
}
