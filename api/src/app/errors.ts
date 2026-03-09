export class HttpError extends Error {
  // Standard error shape used by handlers to map domain failures to HTTP responses.
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string
  ) {
    super(message);
  }
}
