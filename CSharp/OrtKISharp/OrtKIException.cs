namespace OrtKISharp;

/// <summary>
/// Thrown when an onnxruntime operator call fails (invalid inputs, unsupported types, ...).
/// </summary>
public sealed class OrtKIException : Exception
{
    public OrtKIException(string message)
        : base(message)
    {
    }
}
