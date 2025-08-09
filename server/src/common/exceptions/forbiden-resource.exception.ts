import { ForbiddenException } from '@nestjs/common';

export class ForbiddenResourceAppException extends ForbiddenException {
    constructor(message = 'You do not have access to this resource') {
        super(message);
    }
}