namespace TodoApi.Infrastructure.Logging;

public static class LoggingExtensions
{
    public static ILoggingBuilder AddStructuredLogging(this ILoggingBuilder builder, IConfiguration configuration)
    {
        builder.ClearProviders();
        builder.AddConfiguration(configuration.GetSection("Logging"));
        builder.AddConsole();
        builder.AddDebug();

        return builder;
    }
}
