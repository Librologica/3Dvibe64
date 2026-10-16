"""Exact bounded correction for the demo's existing four-pixel carriers.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
"""
from block4 import kernel,once

def baseline():return kernel()[1]

def tail(kind):
    if kind=='baseline':return 'bk_predict_test:\n'+baseline().split('bk_predict_test:\n',1)[1]
    if kind=='fused':
        return '''bk_predict_test:
 sec
 lda bk_delta
 sbc m7_den
 sta bk_delta
 lda bk_delta+1
 sbc #0
 sta bk_delta+1
 bcc b4_restore
 inc bk_future
 bne bk_predict_test
 inc bk_future+1
 jmp bk_predict_test
b4_restore:
 clc
 lda bk_delta
 adc m7_den
 sta bk_delta
 lda bk_delta+1
 adc #0
 sta bk_delta+1
 rts
'''
    if kind in ('compact','compact2'):
        code='''bk_predict_test:
 lda bk_delta+1
 bne b4_high
 lda bk_delta
 cmp m7_den
 bcc bk_predict_done
bk_predict_correct:
 lda bk_delta
 sbc m7_den
 sta bk_delta
 bcs b4_increment
 dec bk_delta+1
b4_increment:
 inc bk_future
 bne bk_predict_test
 inc bk_future+1
 jmp bk_predict_test
b4_high:
 sec
 bcs bk_predict_correct
bk_predict_done:
 rts
'''
        if kind=='compact2':
            code=code.replace('bk_predict_correct:\n lda bk_delta\n','bk_predict_correct:\n')
            code=code.replace('b4_high:\n sec\n','b4_high:\n sec\n lda bk_delta\n')
        return code
    if kind=='lowfast':
        return '''bk_predict_test:
 lda bk_delta+1
 bne b4_high
 lda bk_delta
 cmp m7_den
 bcc bk_predict_done
 sbc m7_den
 sta bk_delta
bk_predict_correct:
 inc bk_future
 bne bk_predict_test
 inc bk_future+1
 jmp bk_predict_test
b4_high:
 sec
 lda bk_delta
 sbc m7_den
 sta bk_delta
 bcs bk_predict_correct
 dec bk_delta+1
 jmp bk_predict_correct
bk_predict_done:
 rts
'''
    if kind=='threshold':
        # D<=111 =>2D<=222, fits one byte. Scratch is overwritten by
        # bk_setup_steps after ALL three predictions; X and Y preserved.
        code='''bk_predict_test:
 lda m7_den
 asl
 sta bk_step0
'''
        for i in range(2):
            code+=f''' lda bk_delta+1
 bne b4_two{i}
 lda bk_delta
 cmp bk_step0
 bcc b4_one
b4_two{i}:
 sec
 lda bk_delta
 sbc bk_step0
 sta bk_delta
 lda bk_delta+1
 sbc #0
 sta bk_delta+1
 clc
 lda bk_future
 adc #2
 sta bk_future
 bcc b4_no_carry{i}
 inc bk_future+1
b4_no_carry{i}:
'''
        code+='''b4_one:
 lda bk_delta
 cmp m7_den
 bcc bk_predict_done
 sbc m7_den
 sta bk_delta
 inc bk_future
 bne bk_predict_done
 inc bk_future+1
bk_predict_done:
 rts
'''
        return code
    raise ValueError(kind)

def body(kind):
    original=baseline();head=original.split('bk_predict_test:\n',1)[0]
    return head+tail(kind)

def adapt(source,parts,placed,kind='compact2'):
    if placed is None:
        parts['perspective_sample']=once(parts['perspective_sample'],baseline(),body(kind))
    return source,parts
