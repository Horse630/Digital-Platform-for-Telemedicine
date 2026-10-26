const crypto = require('crypto');

const TOKEN_TTL_MS = 7 * 24 * 60 * 60 * 1000;

function tokenSecret() {
  const value = process.env.AUTH_TOKEN_SECRET;
  if (!value) {
    throw new Error('AUTH_TOKEN_SECRET is missing. Add it to backend/.env.');
  }
  return value;
}

// Login returns this token. Later requests send it back as a Bearer token.
function signToken(user) {
  const body = Buffer.from(
    JSON.stringify({
      sub: user._id.toString(),
      username: user.username,
      role: user.role,
      exp: Date.now() + TOKEN_TTL_MS,
    }),
  ).toString('base64url');
  const signature = crypto.createHmac('sha256', tokenSecret()).update(body).digest('base64url');
  return `${body}.${signature}`;
}

function readToken(token) {
  if (typeof token !== 'string' || !token.includes('.')) {
    return null;
  }
  const [body, signature] = token.split('.');
  if (!body || !signature) {
    return null;
  }
  const expected = crypto.createHmac('sha256', tokenSecret()).update(body).digest('base64url');
  const actualBuffer = Buffer.from(signature);
  const expectedBuffer = Buffer.from(expected);
  if (
    actualBuffer.length !== expectedBuffer.length ||
    !crypto.timingSafeEqual(actualBuffer, expectedBuffer)
  ) {
    return null;
  }

  try {
    const payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
    if (!payload || payload.exp < Date.now() || !payload.sub || !payload.role) {
      return null;
    }
    return payload;
  } catch (_error) {
    return null;
  }
}

module.exports = { signToken, readToken };
