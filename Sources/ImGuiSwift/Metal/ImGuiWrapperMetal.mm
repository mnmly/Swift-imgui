//
//  ImGuiWrapperMetal.m
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#include "TargetConditionals.h"

#if !(TARGET_OS_SIMULATOR)

#import "ImGuiWrapperMetal.h"
#import <QuartzCore/CAMetalLayer.h>
#include "imgui.h"
#include "ImGuiUtils.h"


void ImGui_ImplMtl_RenderDrawLists (struct ImDrawData *draw_data);
bool ImGui_ImplMtl_CreateDeviceObjects();
bool ImGui_ImplMtl_ReloadFontTexture();
id<MTLBuffer> ImGui_ImplMtl_DequeueReusableBuffer(NSUInteger size);
void ImGui_ImplMtl_EnqueueReusableBuffer(id<MTLBuffer> buffer);
void ImGui_ImplMtl_SetMtlDevice(id<MTLDevice> device);
void ImGui_ImplMtl_SetMtlCommandQueue(id<MTLCommandQueue> queue);
void ImGui_ImplMtl_SetDrawable(id<CAMetalDrawable> drawable);
void ImGui_ImplMtl_SetPixelFormat(MTLPixelFormat format);
void ImGui_ImplMtl_SetDepthPixelFormat(MTLPixelFormat format);

static CAMetalLayer *g_MtlLayer;
static MTLPixelFormat g_MTLPixelFormat = MTLPixelFormatBGRA8Unorm;
static MTLPixelFormat g_MTLDepthPixelFormat = MTLPixelFormatInvalid;

static id<MTLDevice> g_MtlDevice;
static id<MTLCommandQueue> g_MtlCommandQueue;
static id<MTLRenderPipelineState> g_MtlRenderPipelineState;
static id<MTLTexture> g_MtlFontTexture;
static id<MTLSamplerState> g_MtlSamplerState;
static NSMutableArray<id<MTLBuffer>> *g_MtlBufferPool;
static id<CAMetalDrawable> g_MtlCurrentDrawable;
static id<MTLCommandBuffer> g_MtlCommandBuffer;
static id<MTLRenderCommandEncoder> g_MtlRenderCommandEncoder;


@implementation ImGuiWrapperMetal

- (instancetype)initWithDevice: (id<MTLDevice>)device
{
	self = [super init];
	if ( self ) {
		ImGui_ImplMtl_SetMtlDevice(device);
		ImGui_ImplMtl_SetMtlCommandQueue([device newCommandQueue]);
		// _screenScale = [UIScreen mainScreen].scale;
		[self setupImGuiHooks];
	}
	return self;
}

- (instancetype) initWithDevice: (id<MTLDevice> _Nonnull)device font: (NSString* _Nonnull)fontPath
{
	self = [super init];
	if ( self ) {
		ImGui_ImplMtl_SetMtlDevice(device);
		ImGui_ImplMtl_SetMtlCommandQueue([device newCommandQueue]);
        [self setupImGuiHooks: fontPath];
	}
	return self;
}

- (void)setupRenderDrawLists {
	ImGuiIO &io = ImGui::GetIO();
	io.RenderDrawListsFn = ImGui_ImplMtl_RenderDrawLists;
}

- (void)newFrame: (id<CAMetalDrawable>) drawable
{
	ImGui_ImplMtl_CreateDeviceObjects();
	ImGui_ImplMtl_SetDrawable(drawable);
    [self setupMouse];
	ImGui::NewFrame();
}

- (void) newFrameWithCommandEncoder:(id<MTLRenderCommandEncoder> _Nonnull)commandEncoder
{
    ImGui_ImplMtl_CreateDeviceObjects();
    g_MtlRenderCommandEncoder = commandEncoder;
    [self setupMouse];
    ImGui::NewFrame();
}


- (void)setPixelFormat:(MTLPixelFormat)format
{
	ImGui_ImplMtl_SetPixelFormat(format);
}


- (void)setDepthPixelFormat:(MTLPixelFormat)format
{
    ImGui_ImplMtl_SetDepthPixelFormat(format);
}

- (void)reloadFontTexture
{
    ImGui_ImplMtl_ReloadFontTexture();
}

#pragma mark - API

- (void) image: (id<MTLTexture>) userTextureID : (CGSize)size : (CGPoint) uv0 : (CGPoint) uv1 : (CGColorRef _Nonnull) tintColor : (CGColorRef _Nonnull) borderColor
{
	ImGui::Image((__bridge void *)userTextureID, ImGuiUtils::fromCGSize(size));
}

@end



id<MTLBuffer> ImGui_ImplMtl_DequeueReusableBuffer(NSUInteger size) {
	for (int i = 0; i < [g_MtlBufferPool count]; ++i) {
		id<MTLBuffer> candidate = g_MtlBufferPool[i];
		if ([candidate length] >= size) {
			[g_MtlBufferPool removeObjectAtIndex:i];
			return candidate;
		}
	}
	
	return [g_MtlDevice newBufferWithLength:size options:MTLResourceCPUCacheModeDefaultCache];
}

void ImGui_ImplMtl_EnqueueReusableBuffer(id<MTLBuffer> buffer) {
	[g_MtlBufferPool insertObject:buffer atIndex:0];
}

bool ImGui_ImplMtl_ReloadFontTexture()
{
	ImGuiIO& io = ImGui::GetIO();
	unsigned char* pixels;
	int width, height;
	// io.Fonts->GetTexDataAsAlpha8(&pixels, &width, &height);
	io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);
	if (!g_MtlDevice) {
		NSLog(@"Metal is not supported");
		return false;
	}
	
	MTLTextureDescriptor *fontTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																									 width:width
																									height:height
																								 mipmapped:NO];
	g_MtlFontTexture = [g_MtlDevice newTextureWithDescriptor:fontTextureDescriptor];
	MTLRegion region = MTLRegionMake2D(0, 0, width, height);
	[g_MtlFontTexture replaceRegion:region mipmapLevel:0 withBytes:pixels bytesPerRow:width * sizeof(uint8_t) * 4];
    
	// Store our identifier
	io.Fonts->TexID = (void *)(intptr_t)g_MtlFontTexture;
    return true;
}

bool ImGui_ImplMtl_CreateDeviceObjects()
{
	if (g_MtlFontTexture) return true;
	
	// Build texture atlas
	ImGuiIO& io = ImGui::GetIO();
    if ( !ImGui_ImplMtl_ReloadFontTexture() ) { return false; }
	
	MTLSamplerDescriptor *samplerDescriptor = [[MTLSamplerDescriptor alloc] init];
	samplerDescriptor.minFilter = MTLSamplerMinMagFilterNearest;
	samplerDescriptor.magFilter = MTLSamplerMinMagFilterNearest;
	samplerDescriptor.sAddressMode = MTLSamplerAddressModeRepeat;
	samplerDescriptor.tAddressMode = MTLSamplerAddressModeRepeat;
	
	g_MtlSamplerState = [g_MtlDevice newSamplerStateWithDescriptor:samplerDescriptor];
	
	NSString *shaders = @"#include <metal_stdlib>\n\
	using namespace metal;                                                                  \n\
	\n\
	struct vertex_t {                                                                       \n\
	float2 position [[attribute(0)]];                                                   \n\
	float2 tex_coords [[attribute(1)]];                                                 \n\
	uint color [[attribute(2)]];                                                      \n\
	// uchar4 color [[attribute(2)]];                                                      \n\
	};                                                                                      \n\
	\n\
	struct frag_data_t {                                                                    \n\
	float4 position [[position]];                                                       \n\
	float4 color;                                                                       \n\
	float2 tex_coords;                                                                  \n\
	};                                                                                      \n\
	\n\
	vertex frag_data_t vertex_function(vertex_t vertex_in [[stage_in]],                     \n\
	constant float4x4 &proj_matrix [[buffer(1)]])        \n\
	{                                                                                       \n\
	float2 position = vertex_in.position;                                               \n\
	\n\
	frag_data_t out;                                                                    \n\
	out.position = proj_matrix * float4(position.xy, 0, 1);                             \n\
	float a = ((vertex_in.color >> 24) & 255) / 255.0; \n\
	float r = ((vertex_in.color >> 16) & 255) / 255.0; \n\
	float g = ((vertex_in.color >> 8 ) & 255) / 255.0; \n\
	float b = ((vertex_in.color		 ) & 255) / 255.0; \n\
	out.color = float4(b, g, r, a);// * 1.0 / 255.0;                                  \n\
	out.tex_coords = vertex_in.tex_coords;                                              \n\
	return out;                                                                         \n\
	}                                                                                       \n\
	\n\
	fragment float4 fragment_function(frag_data_t frag_in [[stage_in]],                     \n\
	texture2d<float, access::sample> tex [[texture(0)]],  \n\
	sampler tex_sampler [[sampler(0)]])                   \n\
	{                                                                                       \n\
    return frag_in.color * tex.sample(tex_sampler, frag_in.tex_coords);       \n\
	//return tex.sample(tex_sampler, frag_in.tex_coords);       \n\
	}";
	
	NSError *error = nil;
	id<MTLLibrary> library = [g_MtlDevice newLibraryWithSource:shaders options:nil error:&error];
	id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_function"];
	id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_function"];
	
	if (!library || !vertexFunction || !fragmentFunction) {
		NSLog(@"Could not create library from shader source and retrieve functions");
		return false;
	}
	
#define OFFSETOF(TYPE, ELEMENT) ((size_t)&(((TYPE *)0)->ELEMENT))
	MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor vertexDescriptor];
	vertexDescriptor.attributes[0].offset = OFFSETOF(ImDrawVert, pos);
	vertexDescriptor.attributes[0].format = MTLVertexFormatFloat2;
	vertexDescriptor.attributes[0].bufferIndex = 0;
	vertexDescriptor.attributes[1].offset = OFFSETOF(ImDrawVert, uv);
	vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
	vertexDescriptor.attributes[1].bufferIndex = 0;
	vertexDescriptor.attributes[2].offset = OFFSETOF(ImDrawVert, col);
	vertexDescriptor.attributes[2].format = MTLVertexFormatUInt;
	vertexDescriptor.attributes[2].bufferIndex = 0;
	vertexDescriptor.layouts[0].stride = sizeof(ImDrawVert);
	vertexDescriptor.layouts[0].stepRate = 1;
	vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
#undef OFFSETOF
	
	MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
	renderPipelineDescriptor.vertexFunction = vertexFunction;
	renderPipelineDescriptor.fragmentFunction = fragmentFunction;
	renderPipelineDescriptor.vertexDescriptor = vertexDescriptor;
	renderPipelineDescriptor.colorAttachments[0].pixelFormat = g_MTLPixelFormat;

    if (g_MTLDepthPixelFormat != MTLPixelFormatInvalid) {
        renderPipelineDescriptor.depthAttachmentPixelFormat = g_MTLDepthPixelFormat;
    }

	renderPipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
//	renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
//	renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
	renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
	renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
	renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
	renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
	
	g_MtlRenderPipelineState = [g_MtlDevice newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:&error];
	
	if (!g_MtlRenderPipelineState) {
		NSLog(@"Error when creating pipeline state: %@", error);
		return false;
	}
	
	g_MtlBufferPool = [NSMutableArray array];
	
	return true;
}

// This is the main rendering function that you have to implement and provide to ImGui (via setting up 'RenderDrawListsFn' in the ImGuiIO structure)
// If text or lines are blurry when integrating ImGui in your engine:
// - in your Render function, try translating your projection matrix by (0.5f,0.5f) or (0.375f,0.375f)
// NOTE: this is copied pretty much entirely from the opengl3_example, with only minor changes for ES
void ImGui_ImplMtl_RenderDrawLists (ImDrawData *draw_data)
{
	// Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
	ImGuiIO& io = ImGui::GetIO();
	int fb_width = (int)(io.DisplaySize.x * io.DisplayFramebufferScale.x);
	int fb_height = (int)(io.DisplaySize.y * io.DisplayFramebufferScale.y);
	
	if (fb_width == 0 || fb_height == 0) return;
	
	draw_data->ScaleClipRects(io.DisplayFramebufferScale);
	
    id<MTLCommandBuffer> commandBuffer;
    MTLRenderPassDescriptor *renderPassDescriptor;
    id<MTLRenderCommandEncoder> commandEncoder;
    
    if (g_MtlRenderCommandEncoder != NULL) {
        commandEncoder = g_MtlRenderCommandEncoder;
        [commandEncoder setCullMode:MTLCullModeFront];
    } else {
        commandBuffer = [g_MtlCommandQueue commandBuffer];
        renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        renderPassDescriptor.colorAttachments[0].texture = [(id<CAMetalDrawable>)g_MtlCurrentDrawable texture];
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
        commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    }
    
    if (@available(iOS 11_0, *)) {
        [commandBuffer pushDebugGroup:@"ImGui Group"];
    } else {
        // Fallback on earlier versions
    }
    
    [commandEncoder setRenderPipelineState:g_MtlRenderPipelineState];
	
	MTLViewport viewport = {
		.originX = 0, .originY = 0, .width = (double)fb_width, .height = (double)fb_height, .znear = 0, .zfar = 1
	};
	[commandEncoder setViewport:viewport];
	
	float left = 0, right = io.DisplaySize.x, top = 0, bottom = io.DisplaySize.y;
	float near = 0;
	float far = 1;
	float sx = 2 / (right - left);
	float sy = 2 / (top - bottom);
	float sz = 1 / (far - near);
	float tx = (right + left) / (left - right);
	float ty = (top + bottom) / (bottom - top);
	float tz = near / (far - near);
	float orthoMatrix[] = {
		sx,  0,  0, 0,
		0, sy,  0, 0,
		0,  0, sz, 0,
		tx, ty, tz, 1
	};
	
    [commandEncoder setVertexBytes:orthoMatrix length:sizeof(float) * 16 atIndex:1];


	// Render command lists
	for (int n = 0; n < draw_data->CmdListsCount; n++)
	{
		const ImDrawList* cmd_list = draw_data->CmdLists[n];
		const unsigned char* vtx_buffer = (const unsigned char*)&cmd_list->VtxBuffer.front();
		const ImDrawIdx* idx_buffer = &cmd_list->IdxBuffer.front();
		
		NSUInteger vertexBufferSize = sizeof(ImDrawVert) * cmd_list->VtxBuffer.size();
		id<MTLBuffer> vertexBuffer = ImGui_ImplMtl_DequeueReusableBuffer(vertexBufferSize);
		memcpy([vertexBuffer contents], vtx_buffer, vertexBufferSize);
		
		NSUInteger indexBufferSize = sizeof(ImDrawIdx) * cmd_list->IdxBuffer.size();
		id<MTLBuffer> indexBuffer = ImGui_ImplMtl_DequeueReusableBuffer(indexBufferSize);
		memcpy([indexBuffer contents], idx_buffer, indexBufferSize);
		
		[commandEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
		
		int idx_buffer_offset = 0;
		for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.size(); cmd_i++)
		{
			const ImDrawCmd* pcmd = &cmd_list->CmdBuffer[cmd_i];
			if (pcmd->UserCallback)
			{
				pcmd->UserCallback(cmd_list, pcmd);
			}
			else
			{
                MTLScissorRect scissorRect = {
                    .x = (NSUInteger)pcmd->ClipRect.x,
                    .y = (NSUInteger)(pcmd->ClipRect.y),
                    .width = (NSUInteger)(pcmd->ClipRect.z - pcmd->ClipRect.x),
                    .height = (NSUInteger)(pcmd->ClipRect.w - pcmd->ClipRect.y)
                };

                if (scissorRect.x + scissorRect.width <= fb_width && scissorRect.y + scissorRect.height <= fb_height)
                {
                    [commandEncoder setScissorRect:scissorRect];
                }
				
				id<MTLTexture> texId = (__bridge id<MTLTexture>)pcmd->TextureId;
				[commandEncoder setFragmentTexture:texId atIndex:0];
				
				[commandEncoder setFragmentSamplerState:g_MtlSamplerState atIndex:0];
				[commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
										   indexCount:(NSUInteger)pcmd->ElemCount
											indexType:sizeof(ImDrawIdx) == 2 ? MTLIndexTypeUInt16 : MTLIndexTypeUInt32
										  indexBuffer:indexBuffer
									indexBufferOffset:sizeof(ImDrawIdx) * idx_buffer_offset];
			}
			
			idx_buffer_offset += pcmd->ElemCount;
		}
		
        if (g_MtlRenderCommandEncoder == NULL) {
            dispatch_queue_t queue = dispatch_get_main_queue();
            [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
                dispatch_async(queue, ^{
                    ImGui_ImplMtl_EnqueueReusableBuffer(vertexBuffer);
                    ImGui_ImplMtl_EnqueueReusableBuffer(indexBuffer);
                });
            }];
        }

	}
	
    if (g_MtlRenderCommandEncoder == NULL) {
        [commandEncoder endEncoding];
        [commandBuffer commit];
    }
    
    if (@available(iOS 11_0, *)) {
        [commandBuffer popDebugGroup];
    } else {
        // Fallback on earlier versions
    }

}


void ImGui_ImplMtl_SetMtlDevice(id<MTLDevice> device)
{
	g_MtlDevice = device;
}

void ImGui_ImplMtl_SetMtlCommandQueue(id<MTLCommandQueue> queue)
{
	g_MtlCommandQueue = queue;
}

void ImGui_ImplMtl_SetDrawable(id<CAMetalDrawable> drawable)
{
	g_MtlCurrentDrawable = drawable;
}

void ImGui_ImplMtl_SetPixelFormat(MTLPixelFormat format) {
	g_MTLPixelFormat = format;
}

void ImGui_ImplMtl_SetDepthPixelFormat(MTLPixelFormat format) {
    g_MTLDepthPixelFormat = format;
}

#endif
