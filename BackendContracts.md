# Backend & Accelo Integration Contract

Concise contract for the Conquest Support App backend API and how it ties to Accelo. Implement against this when building the real backend.

---

## Architecture

1. **Identity** – Google or Microsoft provides identity (ID token) via the app.
2. **Verification** – Backend verifies the provider token and extracts identity claims.
3. **Resolution** – Backend resolves the identity to an Accelo contact and organization.
4. **Session** – Backend issues an app-specific session token; the app sends this on subsequent requests.
5. **Source of truth** – Accelo remains the source of truth for authorization and business data (invoices, issues, support options, etc.).

```
[App] → Google/Microsoft Sign-In → [Backend] → verify → resolve Accelo contact/org → issue session
[App] ← session token ← [Backend]
[App] → API calls (session in header) → [Backend] → Accelo (authorization + data)
```

---

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/auth/exchange` | Exchange provider ID token for app session (verify identity, resolve contact/org, issue token). |
| GET | `/me` | Current authenticated user and organization (session required). |
| GET | `/invoices` | List invoices for the authenticated contact/org (from Accelo). |
| GET | `/support/options` | Support options available to the user (from Accelo). |
| GET | `/issues` | List support issues for the authenticated contact/org. |
| POST | `/issues` | Create a new support issue. |

All authenticated endpoints expect the app session token (e.g. in `Authorization: Bearer <token>` or a custom header agreed with backend).

---

## Example: Auth Exchange

**Request** – `POST /auth/exchange`

```json
{
  "provider": "google",
  "idToken": "<Google ID token string>"
}
```

`provider` is `"google"` or `"microsoft"`. Backend verifies the token with the provider, resolves to Accelo contact/org, then returns a session.

**Response** – `200 OK`

```json
{
  "session": {
    "token": "<app session token>",
    "expiresAt": "2025-04-01T12:00:00Z",
    "user": {
      "id": "accelo-contact-id",
      "email": "user@example.com",
      "displayName": "Jane Doe"
    },
    "organization": {
      "id": "accelo-org-id",
      "name": "Acme Corp"
    }
  }
}
```

Client stores `session.token` and uses it for `/me`, `/invoices`, `/support/options`, `/issues`, etc. On failure (invalid token, unresolved contact), return an appropriate 4xx with an error payload.

---

## Example: Invoices

**Request** – `GET /invoices` (with session token in header)

Query params (optional): `page`, `limit`, `status`, etc., as agreed.

**Response** – `200 OK`

```json
{
  "invoices": [
    {
      "id": "inv-001",
      "number": "INV-2025-001",
      "status": "paid",
      "amount": 1500.00,
      "currency": "USD",
      "dueDate": "2025-03-15",
      "issuedAt": "2025-03-01T00:00:00Z"
    }
  ],
  "total": 1
}
```

Exact field names and nesting should match Accelo and backend conventions; this is a minimal shape for the contract.

---

## Notes

- **Accelo** – All authorization and business data (invoices, issues, support options) are derived from Accelo; the backend is the bridge between the app and Accelo.
- **Session** – Session token is opaque to the app; backend validates it and maps to Accelo contact/org for each request.
- **Errors** – Use standard HTTP status codes and a consistent error body (e.g. `{ "error": "code", "message": "..." }`) for all endpoints.
