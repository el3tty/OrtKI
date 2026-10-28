#include "c_api.h"
#include <onnx/defs/parser.h>
#include <cstdlib>
#include <cstring>
#include <string>

bool ortki_parse_onnx_text(const char* text, uint8_t** model, size_t* size)
{
    ORTKI_TRY
    onnx::ModelProto proto;
    auto status = onnx::OnnxParser::Parse(proto, text);
    if (!status.IsOK())
    {
        ortki::SetLastError(status.ErrorMessage().c_str());
        return false;
    }

    std::string bytes;
    if (!proto.SerializeToString(&bytes))
    {
        ortki::SetLastError("failed to serialize the parsed ModelProto");
        return false;
    }

    *model = static_cast<uint8_t*>(std::malloc(bytes.size()));
    std::memcpy(*model, bytes.data(), bytes.size());
    *size = bytes.size();
    return true;
    ORTKI_CATCH(false)
}

void ortki_free_buffer(uint8_t* buffer)
{
    std::free(buffer);
}
