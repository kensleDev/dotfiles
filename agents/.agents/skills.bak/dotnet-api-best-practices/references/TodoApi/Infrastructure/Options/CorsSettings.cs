using System.ComponentModel.DataAnnotations;

namespace TodoApi.Infrastructure.Options;

public sealed class CorsSettings
{
    public const string SectionName = "Cors";

    [Required]
    public string[] AllowedOrigins { get; set; } = Array.Empty<string>();

    public bool AllowCredentials { get; set; }
}
