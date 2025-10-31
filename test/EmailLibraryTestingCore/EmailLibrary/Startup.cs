using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
namespace EmailLibrary
{
    internal class Startup
    {
        public static IConfiguration BuildConfiguation()
        {
            return new ConfigurationBuilder()
                .AddUserSecrets<EmailCommands>()
                .Build();
        }
        public static IServiceProvider ConfigureService()
        {
            var provider = new ServiceCollection()
                .BuildServiceProvider();
            return provider;
        }
    }
}
