using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
namespace EmailLibraryTestingCore
{
    internal class Startup
    {
        public static IConfiguration BuildConfiguation()
        {
            return new ConfigurationBuilder()
                .AddUserSecrets<Program>()
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
