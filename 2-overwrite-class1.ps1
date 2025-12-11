@'
using System;

namespace CoverageDemo.Core.Logic
{
    public class Calculator
    {
        public int Add(int a, int b) => a + b;
        public int Subtract(int a, int b) => a - b;
    }
}

namespace CoverageDemo.Core.Utils
{
    public class StringHelper
    {
        public string Reverse(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;
            char[] array = input.ToCharArray();
            Array.Reverse(array);
            return new string(array);
        }
    }
}
'@ > CoverageDemo/CoverageDemo.Core/Class1.cs
