import { BadRequestException, Injectable, PipeTransform } from '@nestjs/common';
@Injectable()
export class ParseBoolQueryPipe implements PipeTransform {
    transform(v: any) {
        if (v === undefined || v === null || v === '') return undefined;
        const s = String(v).toLowerCase();
        if (['true', '1', 'yes'].includes(s)) return true;
        if (['false', '0', 'no'].includes(s)) return false;
        throw new BadRequestException('Invalid boolean');
    }
}