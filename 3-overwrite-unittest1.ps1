@'
using Xunit;
using CoverageDemo.Core.Logic;
using CoverageDemo.Core.Utils;

namespace CoverageDemo.Tests.Logic
{
    public class CalculatorTests
    {
        [Fact]
        public void Add_ReturnsSum()
        {
            var calc = new Calculator();
            Assert.Equal(4, calc.Add(2, 2));
        }

        [Fact]
        public void Subtract_ReturnsDifference()
        {
            var calc = new Calculator();
            Assert.Equal(0, calc.Subtract(2, 2));
        }
    }
}

namespace CoverageDemo.Tests.Utils
{
    public class StringHelperTests
    {
        [Fact]
        public void Reverse_ReturnsReversedString()
        {
            var helper = new StringHelper();
            Assert.Equal("cba", helper.Reverse("abc"));
        }
    }
}
'@ > CoverageDemo/CoverageDemo.Tests/UnitTest1.cs
