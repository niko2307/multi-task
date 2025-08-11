import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const GetUser = createParamDecorator(
    (data: string | undefined, ctx: ExecutionContext) => {
        const request = ctx.switchToHttp().getRequest();
        const user = request.user;

        console.log('🔍 [DEBUG] GetUser decorator - data:', data);
        console.log('🔍 [DEBUG] GetUser decorator - user:', user);
        console.log('🔍 [DEBUG] GetUser decorator - user[data] mirar:', data ? user?.[data] : 'N/A');
        console.log('🔍 [DEBUG] GetUser decorator - URL:', request.url);

        return data ? user?.[data] : user;
    },
);
