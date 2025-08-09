import { CallHandler, ExecutionContext, Injectable, NestInterceptor, RequestTimeoutException } from '@nestjs/common';
import { Observable, TimeoutError, catchError, throwError, timeout } from 'rxjs';

@Injectable()
export class TimeoutInterceptor implements NestInterceptor {
    constructor(private readonly ms = 10_000) { }
    intercept(_: ExecutionContext, next: CallHandler): Observable<any> {
        return next.handle().pipe(
            timeout(this.ms),
            catchError(err => throwError(() => (err instanceof TimeoutError ? new RequestTimeoutException() : err)))
        );
    }
}