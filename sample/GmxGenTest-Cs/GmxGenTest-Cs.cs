using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GmxGenTest {
    public class GmxGenTest {
        // for example:
        ///
        [DllExport]
        public static double ggt_cs_add_numbers(double a, double b) {
            return a + b;
        }

        ///
        [DllExport]
        public static string ggt_cs_add_strings(string a, string b) {
            return a + b;
        }

        ///
        [DllExport]
        public static unsafe void ggt_cs_fill_bytes(byte* buf) {
            buf[0] = 1;
            buf[1] = 2;
        }
    }
}