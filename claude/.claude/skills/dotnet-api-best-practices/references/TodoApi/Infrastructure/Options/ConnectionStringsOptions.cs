using System.ComponentModel.DataAnnotations;

namespace TodoApi.Infrastructure.Options;

public sealed class ConnectionStringsOptions
{
    public const string SectionName = "ConnectionStrings";

    [Required]
    public string? Default { get; set; }
}
