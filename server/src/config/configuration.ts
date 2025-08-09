export default () => ({
    port: parseInt(process.env.PORT ?? '3000', 10),
    jwt: {
        secret: process.env.JWT_SECRET ?? 'dev-secret',
        expiresIn: process.env.JWT_EXPIRES ?? '7d',
    },
    database: {
        url: process.env.DATABASE_URL,      // ← usamos solo esta
        // por partes (opcional si lo necesitas en local):

    },
});
