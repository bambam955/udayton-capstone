export class HttpError extends Error {
  // Throw this from services/routes when you want a controlled API response.
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string
  ) {
    super(message);
  }
}
