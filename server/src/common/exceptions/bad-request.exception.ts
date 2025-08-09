import { BadRequestException } from '@nestjs/common';

export class BadRequestAppException extends BadRequestException {
    constructor(message = 'Bad request') {
        super(message);
    }
}