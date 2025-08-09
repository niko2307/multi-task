import { ConflictException } from '@nestjs/common';

export class DuplicateEmailAppException extends ConflictException {
    constructor(message = 'Email already in use') {
        super(message);
    }
}