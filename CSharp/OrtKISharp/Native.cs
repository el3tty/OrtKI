using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace OrtKISharp;

internal partial class Native
{
    public const string LibraryName = "ortki";

    [DllImport(LibraryName)]
    public static extern unsafe Tensor make_tensor(
        [In] void* buffer, OrtDataType dataType,
        [In] long* shape, nuint shape_size);

    [DllImport(LibraryName)]
    public static extern unsafe Tensor make_tensor_empty(OrtDataType dataType, [In] long* shape, nuint rank);

    [DllImport(LibraryName)]
    public static extern void tensor_dispose(IntPtr tensor);

    [DllImport(LibraryName)]
    public static extern OrtDataType tensor_data_type(Tensor tensor);

    [DllImport(LibraryName)]
    public static extern unsafe void tensor_shape(Tensor tensor, long* shape);

    [DllImport(LibraryName)]
    public static extern nuint tensor_rank(Tensor tensor);

    [DllImport(LibraryName)]
    public static extern nuint tensor_length(Tensor tensor);

    [DllImport(LibraryName)]
    public static extern unsafe void* tensor_buffer(Tensor tensor, out nuint bytes);

    [DllImport(LibraryName)]
    public static extern Tensor tensor_to_type(Tensor tensor, OrtDataType dataType);

    [DllImport(LibraryName)]
    public static extern void tensor_reshape(Tensor tensor, long[] shape, nuint size);

    [DllImport(LibraryName)]
    public static extern void tensor_seq_dispose(IntPtr seq);

    [DllImport(LibraryName)]
    public static extern nuint tensor_seq_size(TensorSeq seq);

    [DllImport(LibraryName)]
    public static extern Tensor tensor_seq_get_value(TensorSeq seq, nuint index);

    [DllImport(LibraryName)]
    private static extern IntPtr ortki_get_last_error();

    [DllImport(LibraryName)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool ortki_parse_onnx_text([MarshalAs(UnmanagedType.LPUTF8Str)] string text, out IntPtr model, out nuint size);

    [DllImport(LibraryName)]
    public static extern void ortki_free_buffer(IntPtr buffer);

    public static string LastError => Marshal.PtrToStringUTF8(ortki_get_last_error()) ?? "unknown ortki error";

    /// <summary>
    /// Operators return a null handle on failure; turn that into an <see cref="OrtKIException"/>.
    /// </summary>
    public static T CheckResult<T>(T result)
        where T : SafeHandle
    {
        if (result.IsInvalid)
        {
            throw new OrtKIException(LastError);
        }

        return result;
    }
}
