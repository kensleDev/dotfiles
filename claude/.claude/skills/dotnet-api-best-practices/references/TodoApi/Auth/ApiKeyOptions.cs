using System.ComponentModel.DataAnnotations;

namespace TodoApi.Auth;

public sealed class ApiKeyOptions
{
    public const string SectionName = "ApiKey";

    public string? HeaderName { get; set; }

    [Required]
    public string? Value { get; set; }
}
