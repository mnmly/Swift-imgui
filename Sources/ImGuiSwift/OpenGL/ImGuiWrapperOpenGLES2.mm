//
//  ImGuiWrapperOpenGLES2.m
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#import "ImGuiWrapperOpenGLES2.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include "imgui.h"
#include "ImGuiUtils.h"

static void ImGui_ImplIOS_RenderDrawLists (ImDrawData *draw_data);
bool ImGui_ImplIOS_CreateDeviceObjects();

static GLuint       g_FontTexture = 0;
static int          g_ShaderHandle = 0, g_VertHandle = 0, g_FragHandle = 0;
static int          g_AttribLocationTex = 0, g_AttribLocationProjMtx = 0;
static int          g_AttribLocationPosition = 0, g_AttribLocationUV = 0, g_AttribLocationColor = 0;
static size_t       g_VboSize = 0;
static unsigned int g_VboHandle = 0, g_VaoHandle = 0;
static float        g_displayScale;

@implementation ImGuiWrapperOpenGLES2
- (instancetype _Nonnull) initWithView: (UIView * _Nonnull)view font: (NSString* _Nullable)fontPath
{
    self = [super init];
    if (self)
    {
        [self setupImGuiHooks: fontPath];
    }
    return self;
}

- (void)setupRenderDrawLists
{
	ImGuiIO &io = ImGui::GetIO();
    io.RenderDrawListsFn = ImGui_ImplIOS_RenderDrawLists;
    g_displayScale = [[UIScreen mainScreen] scale];
}

- (void)newFrame {
    
    if (!g_FontTexture)
    {
        ImGui_ImplIOS_CreateDeviceObjects();
    }
    
    [self setupMouse];
	ImGui::NewFrame();
}

- (void) image: (GLint) userTextureID : (CGSize)size : (CGPoint) uv0 : (CGPoint) uv1 : (CGColorRef _Nonnull) tintColor : (CGColorRef _Nonnull) borderColor
{
    
	ImGui::Image((void *)(intptr_t)userTextureID, ImGuiUtils::fromCGSize(size));
}

@end


// This is the main rendering function that you have to implement and provide to ImGui (via setting up 'RenderDrawListsFn' in the ImGuiIO structure)
// If text or lines are blurry when integrating ImGui in your engine:
// - in your Render function, try translating your projection matrix by (0.5f,0.5f) or (0.375f,0.375f)
// NOTE: this is copied pretty much entirely from the opengl3_example, with only minor changes for ES
static void ImGui_ImplIOS_RenderDrawLists (ImDrawData *draw_data)
{
    // Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled
    GLint last_program, last_texture;
    glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_SCISSOR_TEST);
    glActiveTexture(GL_TEXTURE0);
    
    // Setup orthographic projection matrix
    const float width = ImGui::GetIO().DisplaySize.x;
    const float height = ImGui::GetIO().DisplaySize.y;
    const float ortho_projection[4][4] =
    {
        { 2.0f/width,	0.0f,			0.0f,		0.0f },
        { 0.0f,			2.0f/-height,	0.0f,		0.0f },
        { 0.0f,			0.0f,			-1.0f,		0.0f },
        { -1.0f,		1.0f,			0.0f,		1.0f },
    };
    glUseProgram(g_ShaderHandle);
    glUniform1i(g_AttribLocationTex, 0);
    glUniformMatrix4fv(g_AttribLocationProjMtx, 1, GL_FALSE, &ortho_projection[0][0]);
    glBindVertexArray(g_VaoHandle);
    
    for (int n = 0; n < draw_data->CmdListsCount; n++)
    {
        ImDrawList* cmd_list = draw_data->CmdLists[n];
        ImDrawIdx* idx_buffer = &cmd_list->IdxBuffer.front();
        
        glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
        int needed_vtx_size = cmd_list->VtxBuffer.size() * sizeof(ImDrawVert);
        if (g_VboSize < needed_vtx_size)
        {
            // Grow our buffer if needed
            g_VboSize = needed_vtx_size + 2000 * sizeof(ImDrawVert);
            glBufferData(GL_ARRAY_BUFFER, (GLsizeiptr)g_VboSize, NULL, GL_STREAM_DRAW);
        }
        
        unsigned char* vtx_data = (unsigned char*)glMapBufferRange(GL_ARRAY_BUFFER, 0, needed_vtx_size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
        if (!vtx_data)
            continue;
        memcpy(vtx_data, &cmd_list->VtxBuffer[0], cmd_list->VtxBuffer.size() * sizeof(ImDrawVert));
        glUnmapBuffer(GL_ARRAY_BUFFER);
        
        for (const ImDrawCmd* pcmd = cmd_list->CmdBuffer.begin(); pcmd != cmd_list->CmdBuffer.end(); pcmd++)
        {
            if (pcmd->UserCallback)
            {
                pcmd->UserCallback(cmd_list, pcmd);
            }
            else
            {
                glBindTexture(GL_TEXTURE_2D, (GLuint)(intptr_t)pcmd->TextureId);
                glScissor((int)(pcmd->ClipRect.x * g_displayScale),
                          (int)((height - pcmd->ClipRect.w) * g_displayScale),
                          (int)((pcmd->ClipRect.z - pcmd->ClipRect.x) * g_displayScale),
                          (int)((pcmd->ClipRect.w - pcmd->ClipRect.y) * g_displayScale));
                glDrawElements( GL_TRIANGLES, (GLsizei)pcmd->ElemCount, GL_UNSIGNED_SHORT, idx_buffer );
            }
            idx_buffer += pcmd->ElemCount;
        }
    }
    
    // Restore modified state
    glBindVertexArray(0);
    glBindBuffer( GL_ARRAY_BUFFER, 0);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glUseProgram(last_program);
    glDisable(GL_SCISSOR_TEST);
    glBindTexture(GL_TEXTURE_2D, last_texture);
}

void ImGui_ImplIOS_CreateFontsTexture()
{
    // Build texture atlas
    ImGuiIO& io = ImGui::GetIO();
    unsigned char* pixels;
    int width, height;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);   // Load as RGBA 32-bits for OpenGL3 demo because it is more likely to be compatible with user's existing shader.
    
    // Upload texture to graphics system
    GLint last_texture;
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
    glGenTextures(1, &g_FontTexture);
    glBindTexture(GL_TEXTURE_2D, g_FontTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    
    // Store our identifier
    io.Fonts->TexID = (void *)(intptr_t)g_FontTexture;
    
    // Restore state
    glBindTexture(GL_TEXTURE_2D, last_texture);
}

bool ImGui_ImplIOS_CreateDeviceObjects()
{
    const GLchar *vertex_shader =
    "uniform mat4 ProjMtx;\n"
    "attribute highp vec2 Position;\n"
    "attribute highp vec2 UV;\n"
    "attribute highp vec4 Color;\n"
    "varying vec2 Frag_UV;\n"
    "varying vec4 Frag_Color;\n"
    "void main()\n"
    "{\n"
    "	Frag_UV = UV;\n"
    "	Frag_Color = Color;\n"
    "	gl_Position = ProjMtx * vec4(Position.xy,0,1);\n"
    "}\n";
    
    const GLchar* fragment_shader =
    "uniform sampler2D Texture;\n"
    "varying highp vec2 Frag_UV;\n"
    "varying highp vec4 Frag_Color;\n"
    "void main()\n"
    "{\n"
    "	gl_FragColor = Frag_Color * texture2D( Texture, Frag_UV.st);\n"
    "}\n";
    
    g_ShaderHandle = glCreateProgram();
    g_VertHandle = glCreateShader(GL_VERTEX_SHADER);
    g_FragHandle = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(g_VertHandle, 1, &vertex_shader, 0);
    glShaderSource(g_FragHandle, 1, &fragment_shader, 0);
    glCompileShader(g_VertHandle);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv( g_VertHandle, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(g_VertHandle, logLength, &logLength, log);
        NSLog(@"VERTEX Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glCompileShader(g_FragHandle);
    
#if defined(DEBUG)
    glGetShaderiv( g_FragHandle, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(g_FragHandle, logLength, &logLength, log);
        NSLog(@"FRAGMENT Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glAttachShader(g_ShaderHandle, g_VertHandle);
    glAttachShader(g_ShaderHandle, g_FragHandle);
    glLinkProgram(g_ShaderHandle);
    
    g_AttribLocationTex = glGetUniformLocation(g_ShaderHandle, "Texture");
    g_AttribLocationProjMtx = glGetUniformLocation(g_ShaderHandle, "ProjMtx");
    g_AttribLocationPosition = glGetAttribLocation(g_ShaderHandle, "Position");
    g_AttribLocationUV = glGetAttribLocation(g_ShaderHandle, "UV");
    g_AttribLocationColor = glGetAttribLocation(g_ShaderHandle, "Color");
    
    glGenBuffers(1, &g_VboHandle);
    
    glGenVertexArrays(1, &g_VaoHandle);
    glBindVertexArray(g_VaoHandle);
    glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
    glEnableVertexAttribArray(g_AttribLocationPosition);
    glEnableVertexAttribArray(g_AttribLocationUV);
    glEnableVertexAttribArray(g_AttribLocationColor);
    
#define OFFSETOF(TYPE, ELEMENT) ((size_t)&(((TYPE *)0)->ELEMENT))
    glVertexAttribPointer(g_AttribLocationPosition, 2, GL_FLOAT, GL_FALSE, sizeof(ImDrawVert), (GLvoid*)OFFSETOF(ImDrawVert, pos));
    glVertexAttribPointer(g_AttribLocationUV, 2, GL_FLOAT, GL_FALSE, sizeof(ImDrawVert), (GLvoid*)OFFSETOF(ImDrawVert, uv));
    glVertexAttribPointer(g_AttribLocationColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(ImDrawVert), (GLvoid*)OFFSETOF(ImDrawVert, col));
#undef OFFSETOF
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    ImGui_ImplIOS_CreateFontsTexture();
    
    return true;
}
