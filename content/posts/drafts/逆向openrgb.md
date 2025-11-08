```txt
# tracer: nop
#
# entries-in-buffer/entries-written: 0/0   #P:32
#
#                                _-----=> irqs-off/BH-disabled
#                               / _----=> need-resched
#                              | / _---=> hardirq/softirq
#                              || / _--=> preempt-depth
#                              ||| / _-=> migrate-disable
#                              |||| /     delay
#           TASK-PID     CPU#  |||||  TIMESTAMP  FUNCTION
#              | |         |   |||||     |         |
         openrgb-108143  [001] ..... 20335.351269: i2c_read: i2c-1 #0 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.351535: i2c_reply: i2c-1 #0 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.351536: i2c_result: i2c-1 n=1 ret=1
         openrgb-108143  [001] ..... 20335.351544: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a0]
         openrgb-108143  [001] ..... 20335.351544: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.351946: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.351946: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.351955: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a1]
         openrgb-108143  [001] ..... 20335.351955: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.352357: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.352357: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.352365: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a2]
         openrgb-108143  [001] ..... 20335.352365: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.352767: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.352767: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.352774: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a3]
         openrgb-108143  [001] ..... 20335.352774: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.353177: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.353177: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.353185: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a4]
         openrgb-108143  [001] ..... 20335.353186: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.353588: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.353588: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.353594: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a5]
         openrgb-108143  [001] ..... 20335.353594: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.353996: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.353996: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.354001: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a6]
         openrgb-108143  [001] ..... 20335.354001: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.354407: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.354407: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.354415: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a7]
         openrgb-108143  [001] ..... 20335.354415: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.354817: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.354817: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.354822: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a8]
         openrgb-108143  [001] ..... 20335.354823: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.355224: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.355224: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.355231: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [a9]
         openrgb-108143  [001] ..... 20335.355231: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.355633: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.355633: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.355639: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [aa]
         openrgb-108143  [001] ..... 20335.355639: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.356041: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.356041: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.356048: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [ab]
         openrgb-108143  [001] ..... 20335.356048: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.356451: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.356451: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.356458: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [ac]
         openrgb-108143  [001] ..... 20335.356458: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.356860: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.356860: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.356865: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [ad]
         openrgb-108143  [001] ..... 20335.356865: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.357268: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.357268: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.357274: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [ae]
         openrgb-108143  [001] ..... 20335.357274: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.357676: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.357676: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.357682: i2c_write: i2c-1 #0 a=040 f=0000 l=1 [af]
         openrgb-108143  [001] ..... 20335.357682: i2c_read: i2c-1 #1 a=040 f=0001 l=1
         openrgb-108143  [001] ..... 20335.358084: i2c_reply: i2c-1 #1 a=040 f=0001 l=1 [00]
         openrgb-108143  [001] ..... 20335.358084: i2c_result: i2c-1 n=2 ret=2
         openrgb-108143  [001] ..... 20335.359151: i2c_read: i2c-1 #0 a=04e f=0001 l=1
         openrgb-108143  [001] ..... 20335.359274: i2c_result: i2c-1 n=1 ret=-121
         openrgb-108143  [001] ..... 20335.359283: i2c_write: i2c-1 #0 a=04e f=0000 l=1 [00]
         openrgb-108143  [001] ..... 20335.359283: i2c_read: i2c-1 #1 a=04e f=0001 l=1
         openrgb-108143  [001] ..... 20335.359403: i2c_result: i2c-1 n=2 ret=-121
         openrgb-108143  [001] ..... 20335.360462: i2c_read: i2c-1 #0 a=04f f=0001 l=1
         openrgb-108143  [001] ..... 20335.360583: i2c_result: i2c-1 n=1 ret=-121
         openrgb-108143  [001] ..... 20335.360589: i2c_write: i2c-1 #0 a=04f f=0000 l=1 [00]
         openrgb-108143  [001] ..... 20335.360589: i2c_read: i2c-1 #1 a=04f f=0001 l=1
         openrgb-108143  [001] ..... 20335.360709: i2c_result: i2c-1 n=2 ret=-121
         openrgb-108146  [018] ..... 20335.368251: i2c_read: i2c-6 #0 a=040 f=0001 l=1
         openrgb-108146  [018] ..... 20335.368309: i2c_result: i2c-6 n=1 ret=-5
         openrgb-108146  [018] ..... 20335.368336: i2c_write: i2c-6 #0 a=040 f=0000 l=1 [00]
         openrgb-108146  [018] ..... 20335.368336: i2c_read: i2c-6 #1 a=040 f=0001 l=1
         openrgb-108146  [018] ..... 20335.368387: i2c_result: i2c-6 n=2 ret=-5
         openrgb-108146  [018] ..... 20335.369467: i2c_read: i2c-6 #0 a=04e f=0001 l=1
         openrgb-108146  [018] ..... 20335.369518: i2c_result: i2c-6 n=1 ret=-5
         openrgb-108146  [018] ..... 20335.369523: i2c_write: i2c-6 #0 a=04e f=0000 l=1 [00]
         openrgb-108146  [018] ..... 20335.369523: i2c_read: i2c-6 #1 a=04e f=0001 l=1
         openrgb-108146  [018] ..... 20335.369569: i2c_result: i2c-6 n=2 ret=-5
         openrgb-108146  [018] ..... 20335.370627: i2c_read: i2c-6 #0 a=04f f=0001 l=1
         openrgb-108146  [018] ..... 20335.370673: i2c_result: i2c-6 n=1 ret=-5
         openrgb-108146  [018] ..... 20335.370679: i2c_write: i2c-6 #0 a=04f f=0000 l=1 [00]
         openrgb-108146  [018] ..... 20335.370679: i2c_read: i2c-6 #1 a=04f f=0001 l=1
         openrgb-108146  [018] ..... 20335.370725: i2c_result: i2c-6 n=2 ret=-5
         openrgb-108152  [024] ..... 20335.378157: i2c_read: i2c-0 #0 a=040 f=0001 l=1
         openrgb-108152  [024] ..... 20335.378290: i2c_result: i2c-0 n=1 ret=-121
         openrgb-108152  [024] ..... 20335.378304: i2c_write: i2c-0 #0 a=040 f=0000 l=1 [00]
         openrgb-108152  [024] ..... 20335.378304: i2c_read: i2c-0 #1 a=040 f=0001 l=1
         openrgb-108152  [024] ..... 20335.378365: i2c_result: i2c-0 n=2 ret=-121
         openrgb-108152  [024] ..... 20335.379429: i2c_read: i2c-0 #0 a=04e f=0001 l=1
         openrgb-108152  [024] ..... 20335.379488: i2c_result: i2c-0 n=1 ret=-121
         openrgb-108152  [024] ..... 20335.379497: i2c_write: i2c-0 #0 a=04e f=0000 l=1 [00]
         openrgb-108152  [024] ..... 20335.379497: i2c_read: i2c-0 #1 a=04e f=0001 l=1
         openrgb-108152  [024] ..... 20335.379556: i2c_result: i2c-0 n=2 ret=-121
         openrgb-108152  [024] ..... 20335.380616: i2c_read: i2c-0 #0 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.380699: i2c_reply: i2c-0 #0 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.380699: i2c_result: i2c-0 n=1 ret=1
         openrgb-108152  [024] ..... 20335.380707: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a0]
         openrgb-108152  [024] ..... 20335.380707: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.380846: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.380846: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.380852: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a1]
         openrgb-108152  [024] ..... 20335.380852: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.380996: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.380996: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.381004: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a2]
         openrgb-108152  [024] ..... 20335.381004: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.381161: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.381161: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.381169: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a3]
         openrgb-108152  [024] ..... 20335.381169: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.381308: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.381308: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.381316: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a4]
         openrgb-108152  [024] ..... 20335.381316: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.381462: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.381462: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.381470: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a5]
         openrgb-108152  [024] ..... 20335.381470: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.381611: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.381612: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.381621: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a6]
         openrgb-108152  [024] ..... 20335.381621: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [024] ..... 20335.381765: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [024] ..... 20335.381765: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [024] ..... 20335.381773: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a7]
         openrgb-108152  [024] ..... 20335.381773: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [002] ..... 20335.381914: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [002] ..... 20335.381915: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [002] ..... 20335.381923: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a8]
         openrgb-108152  [002] ..... 20335.381923: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [020] ..... 20335.382081: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [020] ..... 20335.382081: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [020] ..... 20335.382090: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a9]
         openrgb-108152  [020] ..... 20335.382091: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [020] ..... 20335.382228: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [020] ..... 20335.382228: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [020] ..... 20335.382235: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [aa]
         openrgb-108152  [020] ..... 20335.382235: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [020] ..... 20335.382371: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [020] ..... 20335.382371: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [020] ..... 20335.382377: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ab]
         openrgb-108152  [020] ..... 20335.382377: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [020] ..... 20335.382515: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [020] ..... 20335.382515: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [020] ..... 20335.382524: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ac]
         openrgb-108152  [020] ..... 20335.382524: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [001] ..... 20335.382564: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [001] ..... 20335.382565: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [002] ..... 20335.382703: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ad]
         openrgb-108152  [002] ..... 20335.382703: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [018] ..... 20335.382862: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [018] ..... 20335.382862: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [016] ..... 20335.382994: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ae]
         openrgb-108152  [016] ..... 20335.382994: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [028] .n... 20335.383182: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [027] ..... 20335.383187: i2c_result: i2c-0 n=2 ret=2
         openrgb-108152  [027] ..... 20335.383199: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [af]
         openrgb-108152  [027] ..... 20335.383199: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-108152  [027] ..... 20335.383339: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-108152  [027] ..... 20335.383340: i2c_result: i2c-0 n=2 ret=2
         openrgb-108154  [005] ..... 20335.384405: i2c_read: i2c-7 #0 a=040 f=0001 l=1
         openrgb-108154  [005] ..... 20335.384461: i2c_result: i2c-7 n=1 ret=-5
         openrgb-108154  [005] ..... 20335.384466: i2c_write: i2c-7 #0 a=040 f=0000 l=1 [00]
         openrgb-108154  [005] ..... 20335.384466: i2c_read: i2c-7 #1 a=040 f=0001 l=1
         openrgb-108154  [005] ..... 20335.384514: i2c_result: i2c-7 n=2 ret=-5
         openrgb-108154  [005] ..... 20335.385573: i2c_read: i2c-7 #0 a=04e f=0001 l=1
         openrgb-108154  [005] ..... 20335.385625: i2c_result: i2c-7 n=1 ret=-5
         openrgb-108154  [005] ..... 20335.385631: i2c_write: i2c-7 #0 a=04e f=0000 l=1 [00]
         openrgb-108154  [005] ..... 20335.385631: i2c_read: i2c-7 #1 a=04e f=0001 l=1
         openrgb-108154  [005] ..... 20335.385678: i2c_result: i2c-7 n=2 ret=-5
         openrgb-108154  [005] ..... 20335.386737: i2c_read: i2c-7 #0 a=04f f=0001 l=1
         openrgb-108154  [005] ..... 20335.386784: i2c_result: i2c-7 n=1 ret=-5
         openrgb-108154  [005] ..... 20335.386790: i2c_write: i2c-7 #0 a=04f f=0000 l=1 [00]
         openrgb-108154  [005] ..... 20335.386790: i2c_read: i2c-7 #1 a=04f f=0001 l=1
         openrgb-108154  [005] ..... 20335.386837: i2c_result: i2c-7 n=2 ret=-5
```




```txt
         openrgb-110926  [027] ..... 20766.240588: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [027] ..... 20766.240588: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [027] ..... 20766.240596: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [a9]
         openrgb-110926  [027] ..... 20766.240596: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [027] ..... 20766.240734: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [027] ..... 20766.240734: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [027] ..... 20766.240743: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [aa]
         openrgb-110926  [027] ..... 20766.240743: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [027] ..... 20766.240882: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [027] ..... 20766.240882: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [027] ..... 20766.240889: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ab]
         openrgb-110926  [027] ..... 20766.240889: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [027] ..... 20766.241026: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [027] ..... 20766.241026: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [027] ..... 20766.241033: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ac]
         openrgb-110926  [027] ..... 20766.241033: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [027] ..... 20766.241171: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [027] ..... 20766.241171: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [027] ..... 20766.241179: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ad]
         openrgb-110926  [027] ..... 20766.241179: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [027] ..... 20766.241325: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [027] ..... 20766.241325: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [004] ..... 20766.241343: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [ae]
         openrgb-110926  [004] ..... 20766.241344: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [004] ..... 20766.241485: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [004] ..... 20766.241485: i2c_result: i2c-0 n=2 ret=2
         openrgb-110926  [004] ..... 20766.241516: i2c_write: i2c-0 #0 a=04f f=0000 l=1 [af]
         openrgb-110926  [004] ..... 20766.241516: i2c_read: i2c-0 #1 a=04f f=0001 l=1
         openrgb-110926  [004] ..... 20766.241661: i2c_reply: i2c-0 #1 a=04f f=0001 l=1 [00]
         openrgb-110926  [004] ..... 20766.241661: i2c_result: i2c-0 n=2 ret=2
         openrgb-110928  [027] ..... 20766.242725: i2c_read: i2c-7 #0 a=040 f=0001 l=1
         openrgb-110928  [027] ..... 20766.242779: i2c_result: i2c-7 n=1 ret=-5
         openrgb-110928  [027] ..... 20766.242787: i2c_write: i2c-7 #0 a=040 f=0000 l=1 [00]
         openrgb-110928  [027] ..... 20766.242787: i2c_read: i2c-7 #1 a=040 f=0001 l=1
         openrgb-110928  [009] ..... 20766.242845: i2c_result: i2c-7 n=2 ret=-5
         openrgb-110928  [009] ..... 20766.243908: i2c_read: i2c-7 #0 a=04e f=0001 l=1
         openrgb-110928  [009] ..... 20766.243968: i2c_result: i2c-7 n=1 ret=-5
         openrgb-110928  [009] ..... 20766.243977: i2c_write: i2c-7 #0 a=04e f=0000 l=1 [00]
         openrgb-110928  [009] ..... 20766.243977: i2c_read: i2c-7 #1 a=04e f=0001 l=1
         openrgb-110928  [009] ..... 20766.244025: i2c_result: i2c-7 n=2 ret=-5
         openrgb-110928  [009] ..... 20766.245086: i2c_read: i2c-7 #0 a=04f f=0001 l=1
         openrgb-110928  [009] ..... 20766.245138: i2c_result: i2c-7 n=1 ret=-5
         openrgb-110928  [009] ..... 20766.245146: i2c_write: i2c-7 #0 a=04f f=0000 l=1 [00]
         openrgb-110928  [009] ..... 20766.245146: i2c_read: i2c-7 #1 a=04f f=0001 l=1
         openrgb-110928  [009] ..... 20766.245194: i2c_result: i2c-7 n=2 ret=-5

```