# https://raw.githubusercontent.com/nimious/egl/master/src/egl.nim
# The MIT License (MIT)
#
# Copyright (c) 2016 
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import system

{.pragma: eglImport, cdecl, importc.}

type
  NativeDisplayType* = pointer
  EGLNativeDisplayType* = pointer
  NativePixmapType* = pointer
  EGLNativePixmapType* = pointer
  NativeWindowType* = pointer
  EGLNativeWindowType* = pointer

  # Define EGLint. This must be a signed integral type large enough to contain
  # all legal attribute names and values passed into and out of EGL, whether
  # their type is boolean, bitmask, enumerant (symbolic constant), integer,
  # handle, or other.  While in general a 32-bit integer will suffice, if
  # handles are 64 bit types, then EGLint should be defined as a signed 64-bit
  # integer type.
type
  EGLInt* = int32


type
  EGLBoolean* = cuint
  EGLDisplay* = pointer
  EGLConfig* = pointer
  EGLSurface* = pointer
  EGLContext* = pointer


type
  EGLAttribList* = seq[EGLInt]
  EGLMustCastToProperProcType* = pointer


const
  EGL_ALPHA_SIZE* = 0x00003021
  EGL_BAD_ACCESS* = 0x00003002
  EGL_BAD_ALLOC* = 0x00003003
  EGL_BAD_ATTRIBUTE* = 0x00003004
  EGL_BAD_CONFIG* = 0x00003005
  EGL_BAD_CONTEXT* = 0x00003006
  EGL_BAD_CURRENT_SURFACE* = 0x00003007
  EGL_BAD_DISPLAY* = 0x00003008
  EGL_BAD_MATCH* = 0x00003009
  EGL_BAD_NATIVE_PIXMAP* = 0x0000300A
  EGL_BAD_NATIVE_WINDOW* = 0x0000300B
  EGL_BAD_PARAMETER* = 0x0000300C
  EGL_BAD_SURFACE* = 0x0000300D
  EGL_BLUE_SIZE* = 0x00003022
  EGL_BUFFER_SIZE* = 0x00003020
  EGL_CONFIG_CAVEAT* = 0x00003027
  EGL_CONFIG_ID* = 0x00003028
  EGL_CORE_NATIVE_ENGINE* = 0x0000305B
  EGL_DEPTH_SIZE* = 0x00003025
  EGL_DONT_CARE* = -1
  EGL_DRAW* = 0x00003059
  EGL_EXTENSIONS* = 0x00003055
  EGL_FALSE* = 0
  EGL_GREEN_SIZE* = 0x00003023
  EGL_HEIGHT* = 0x00003056
  EGL_LARGEST_PBUFFER* = 0x00003058
  EGL_LEVEL* = 0x00003029
  EGL_MAX_PBUFFER_HEIGHT* = 0x0000302A
  EGL_MAX_PBUFFER_PIXELS* = 0x0000302B
  EGL_MAX_PBUFFER_WIDTH* = 0x0000302C
  EGL_NATIVE_RENDERABLE* = 0x0000302D
  EGL_NATIVE_VISUAL_ID* = 0x0000302E
  EGL_NATIVE_VISUAL_TYPE* = 0x0000302F
  EGL_NONE* = 0x00003038
  EGL_NON_CONFORMANT_CONFIG* = 0x00003051
  EGL_NOT_INITIALIZED* = 0x00003001
  EGL_NO_CONTEXT* = (cast[EGLContext](0))
  EGL_NO_DISPLAY* = (cast[EGLDisplay](0))
  EGL_NO_SURFACE* = (cast[EGLSurface](0))
  EGL_PBUFFER_BIT* = 0x00000001
  EGL_PIXMAP_BIT* = 0x00000002
  EGL_READ* = 0x0000305A
  EGL_RED_SIZE* = 0x00003024
  EGL_SAMPLES* = 0x00003031
  EGL_SAMPLE_BUFFERS* = 0x00003032
  EGL_SLOW_CONFIG* = 0x00003050
  EGL_STENCIL_SIZE* = 0x00003026
  EGL_SUCCESS* = 0x00003000
  EGL_SURFACE_TYPE* = 0x00003033
  EGL_TRANSPARENT_BLUE_VALUE* = 0x00003035
  EGL_TRANSPARENT_GREEN_VALUE* = 0x00003036
  EGL_TRANSPARENT_RED_VALUE* = 0x00003037
  EGL_TRANSPARENT_RGB* = 0x00003052
  EGL_TRANSPARENT_TYPE* = 0x00003034
  EGL_TRUE* = 1
  EGL_VENDOR* = 0x00003053
  EGL_VERSION* = 0x00003054
  EGL_WIDTH* = 0x00003057
  EGL_WINDOW_BIT* = 0x00000004


proc eglChooseConfig*(display: EGLDisplay; attribList: ptr EGLInt;
  configs: ptr EGLConfig; configSize: EGLint; numConfig: ptr EGLint): EGLBoolean
  {.eglImport.}
  ## Return a list of EGL frame buffer configurations that match specified
  ## attributes.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## attribList
  ##   Specifies attributes required to match by configs.
  ## configs
  ##   Returns an array of frame buffer configurations.
  ## configSize
  ##   Specifies the size of the array of frame buffer configurations.
  ## numConfig
  ##   Returns the number of frame buffer configurations returned.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` on failure.
  ##
  ## `configs` and `numConfig` are not modified when `EGL_FALSE` is returned.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_BAD_ATTRIBUTE` if `attributeList` contains an invalid frame buffer
  ##   configuration attribute or an attribute value that is unrecognized or out
  ##   of range.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_PARAMETER` if num_config is `nil`.


proc eglCopyBuffers*(display: EGLDisplay; surface: EGLSurface;
  nativePixmap: EGLNativePixmapType): EGLBoolean {.eglImport.}
  ## Copy EGL surface color buffer to a native pixmap.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL surface whose color buffer is to be copied.
  ## nativePixmap
  ##   Specifies the native pixmap as target of the copy.
  ## result
  ##   `EGL_FALSE` if swapping of the buffers failed, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_SURFACE` if `surface` is not an EGL drawing surface.
  ## - `EGL_BAD_NATIVE_PIXMAP` if the implementation does not support native
  ##   pixmaps.
  ## - `EGL_BAD_NATIVE_PIXMAP` if `nativePixmap` is not a valid native pixmap.
  ## - `EGL_BAD_MATCH` if the format of `nativePixmap` is not compatible with
  ##   the color buffer of surface.
  ## - `EGL_CONTEXT_LOST` if a power management event has occurred. The
  ##   application must destroy all contexts and reinitialise OpenGL ES state
  ##   and objects to continue rendering.


proc eglCreateContext*(display: EGLDisplay; config: EGLConfig;
  shareContext: EGLContext; attribList: ptr EGLint): EGLContext {.eglImport.}
  ## Create a new EGL rendering context.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the EGL frame buffer configuration that defines the frame
  ##   buffer resource available to the rendering context.
  ## shareContext
  ##   Specifies another EGL rendering context with which to share data, as
  ##   defined by the client API corresponding to the contexts. Data is also
  ##   shared with all other contexts with which `shareContext` shares data.
  ##   `EGL_NO_CONTEXT` indicates that no sharing is to take place.
  ## attribList
  ##   Specifies attributes and attribute values for the context being created.
  ##   Only the attribute EGL_CONTEXT_CLIENT_VERSION may be specified.
  ## result
  ##   `EGL_NO_CONTEXT` if creation of the context fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_MATCH` if the current rendering API is `EGL_NONE` (this can only
  ##   arise in an EGL implementation which does not support OpenGL ES, prior to
  ##   the first call to `eglBindAPI <#eglBindAPI>`_).
  ## - `EGL_BAD_MATCH` if the server context state for `shareContext` exists in
  ##   an address space which cannot be shared with the newly created context,
  ##   if `shareContext` was created on a different display than the one
  ##   referenced by `config`, or if the contexts are otherwise incompatible.
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONFIG` if `config` is not an EGL frame buffer configuration, or
  ##   does not support the current rendering API. This includes requesting
  ##   creation of an OpenGL ES 1.x context when the `EGL_RENDERABLE_TYPE`
  ##   attribute of config does not contain `EGL_OPENGL_ES_BIT`, or creation of
  ##   an OpenGL ES 2.x context when the attribute does not contain
  ##   `EGL_OPENGL_ES2_BIT`.
  ## - `EGL_BAD_CONTEXT` if `shareContext` is not an EGL rendering context of
  ##   the same client API type as the newly created context and is not
  ##   `EGL_NO_CONTEXT`.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains an invalid context attribute
  ##   or if an attribute is not recognized or out of range. Note that attribute
  ##   `EGL_CONTEXT_CLIENT_VERSION` is only valid when the current rendering API
  ##   is `EGL_OPENGL_ES_API`.
  ## - `EGL_BAD_ALLOC` if there are not enough resources to allocate the new
  ##   context.


proc eglCreatePbufferSurface*(display: EGLDisplay; config: EGLConfig;
  attribList: ptr EGLint): EGLSurface {.eglImport.}
  ## Create a new EGL pixel buffer surface.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the EGL frame buffer configuration that defines the frame
  ##   buffer resource available to the surface.
  ## attribList
  ##   Specifies pixel buffer surface attributes. May be `nil` or empty (first
  ##   attribute is `EGL_NONE`).
  ## result
  ##   `EGL_NO_SURFACE` if creation of the context fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONFIG` if `config` is not an EGL frame buffer configuration.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains an invalid pixel buffer
  ##   attribute or if an attribute value is not recognized or out of range.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains any of the attributes
  ##   `EGL_MIPMAP_TEXTURE`, `EGL_TEXTURE_FORMAT`, or `EGL_TEXTURE_TARGET`, and
  ##   `config` does not support OpenGL ES rendering (e.g. the EGL version is
  ##   1.2 or later, and the `EGL_RENDERABLE_TYPE` attribute of config does not
  ##   include at least one of `EGL_OPENGL_ES_BIT` or `EGL_OPENGL_ES2_BIT`).
  ## - `EGL_BAD_ALLOC` if there are not enough resources to allocate the new
  ##   surface.
  ## - `EGL_BAD_MATCH` if config does not support rendering to pixel buffers
  ##   (the `EGL_SURFACE_TYPE` attribute does not contain `EGL_PBUFFER_BIT`).
  ## - `EGL_BAD_MATCH` if the `EGL_TEXTURE_FORMAT` attribute is not
  ##   `EGL_NO_TEXTURE`, and `EGL_WIDTH` and/or `EGL_HEIGHT` specify an invalid
  ##   size (e.g., the texture size is not a power of 2, and the underlying
  ##   OpenGL ES implementation does not support non-power-of-two textures).
  ## - `EGL_BAD_MATCH` if the `EGL_TEXTURE_FORMAT` attribute is
  ##   `EGL_NO_TEXTURE`, and `EGL_TEXTURE_TARGET` is something other than
  ##   `EGL_NO_TEXTURE`; or, `EGL_TEXTURE_FORMAT` is something other than
  ##   `EGL_NO_TEXTURE`, and `EGL_TEXTURE_TARGET` is `EGL_NO_TEXTURE`.
  ## - `EGL_BAD_MATCH` if config does not support the specified OpenVG alpha
  ##   format attribute (the value of `EGL_VG_ALPHA_FORMAT` is
  ##   `EGL_VG_ALPHA_FORMAT_PRE` and the `EGL_VG_ALPHA_FORMAT_PRE_BIT` is not
  ##   set in the `EGL_SURFACE_TYPE` attribute of `config`) or colorspace
  ##   attribute (the value of `EGL_VG_COLORSPACE` is `EGL_VG_COLORSPACE_LINEAR`
  ##   and the `EGL_VG_COLORSPACE_LINEAR_IT` is not set in the
  ##   `EGL_SURFACE_TYPE` attribute of `config`).


proc eglCreatePixmapSurface*(display: EGLDisplay; config: EGLConfig;
  nativePixmap: EGLNativePixmapType; attribList: ptr EGLint): EGLSurface
  {.eglImport.}
  ## Create a new EGL pixmap surface.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the EGL frame buffer configuration that defines the frame
  ##   buffer resource available to the surface.
  ## nativePixmap
  ##   Specifies the native pixmap.
  ## attribList
  ##   Specifies pixmap surface attributes. May be `nil` or empty (first
  ##   attribute is `EGL_NONE`).
  ## result
  ##   `EGL_NO_SURFACE` if creation of the context fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONFIG` if config is not an EGL config.
  ## - `EGL_BAD_NATIVE_PIXMAP` if `nativePixmap` is not a valid native pixmap.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains an invalid pixmap attribute
  ##   or if an attribute value is not recognized or out of range.
  ## - `EGL_BAD_ALLOC` if there are not enough resources to allocate the new
  ##   surface.
  ## - `EGL_BAD_MATCH` if the attributes of `nativePixmap` do not correspond to
  ##   config or if config does not support rendering to pixmaps (the
  ##   `EGL_SURFACE_TYPE` attribute does not contain `EGL_PIXMAP_BIT`).
  ## - `EGL_BAD_MATCH` if config does not support the specified OpenVG alpha
  ##   format attribute (the value of `EGL_VG_ALPHA_FORMAT` is
  ##   `EGL_VG_ALPHA_FORMAT_PRE` and the `EGL_VG_ALPHA_FORMAT_PRE_BIT` is not
  ##   set in the `EGL_SURFACE_TYPE` attribute of `config`) or colorspace
  ##   attribute (the value of `EGL_VG_COLORSPACE` is `EGL_VG_COLORSPACE_LINEAR`
  ##   and the `EGL_VG_COLORSPACE_LINEAR_IT` is not set in the
  ##   `EGL_SURFACE_TYPE` attribute of `config`).


proc eglCreateWindowSurface*(display: EGLDisplay; config: EGLConfig;
  nativeWindow: EGLNativeWindowType; attribList: ptr EGLint): EGLSurface
  {.eglImport.}
  ## Create a new EGL window surface.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the EGL frame buffer configuration that defines the frame
  ##   buffer resource available to the surface.
  ## nativeWindow
  ##   Specifies the native window.
  ## attribList
  ##   Specifies window surface attributes. May be `nil` or empty (first
  ##  attribute is `EGL_NONE`).
  ## result
  ##   `EGL_NO_SURFACE` if creation of the context fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONFIG` if config is not an EGL frame buffer configuration.
  ## - `EGL_BAD_NATIVE_WINDOW` if native_window is not a valid native window.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains an invalid window attribute
  ##   or if an attribute value is not recognized or is out of range.
  ## - `EGL_BAD_ALLOC` if there are not enough resources to allocate the new
  ##   surface.
  ## - `EGL_BAD_MATCH` if the attributes of `nativeWindow` do not correspond to
  ##   config or if config does not support rendering to windows (the
  ##   `EGL_SURFACE_TYPE` attribute does not contain `EGL_WINDOW_BIT`).
  ## - `EGL_BAD_MATCH` if config does not support the specified OpenVG alpha
  ##   format attribute (the value of `EGL_VG_ALPHA_FORMAT` is
  ##   `EGL_VG_ALPHA_FORMAT_PRE` and the `EGL_VG_ALPHA_FORMAT_PRE_BIT` is not
  ##   set in the `EGL_SURFACE_TYPE attribute of `config`) or colorspace
  ##   attribute (the value of `EGL_VG_COLORSPACE` is `EGL_VG_COLORSPACE_LINEAR`
  ##   and the `EGL_VG_COLORSPACE_LINEAR_IT` is not set in the
  ##   `EGL_SURFACE_TYPE` attribute of `config`).


proc eglDestroyContext*(display: EGLDisplay; context: EGLContext): EGLBoolean
  {.eglImport.}
  ## Destroy an EGL rendering context.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## context
  ##   Specifies the EGL rendering context to be destroyed.
  ## result
  ##   `EGL_FALSE` if destruction of the context fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONTEXT` if `context` is not an EGL rendering context.


proc eglDestroySurface*(display: EGLDisplay; surface: EGLSurface): EGLBoolean
  {.eglImport.}
  ## Destroy an EGL surface.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL surface to be destroyed.
  ## result
  ##   `EGL_FALSE` if destruction of the surface fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_SURFACE` if `surface` is not an EGL surface.


proc eglGetConfigAttrib*(display: EGLDisplay; config: EGLConfig;
  attribute: EGLint; value: ptr EGLint): EGLBoolean {.eglImport.}
  ## Return information about an EGL frame buffer configuration.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the EGL frame buffer configuration to be queried.
  ## attribute
  ##   Specifies the EGL rendering context attribute to be returned.
  ## value
  ##   Returns the requested value.
  ## result
  ##   `EGL_FALSE` on failure, `EGL_TRUE` otherwise. `value` is not modified
  ##   when `EGL_FALSE` is returned.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONFIG` if config is not an EGL frame buffer configuration.
  ## - `EGL_BAD_ATTRIBUTE` if attribute is not a valid frame buffer
  ##   configuration attribute.


proc eglGetConfigs*(display: EGLDisplay; configs: ptr EGLConfig;
  configSize: EGLint; numConfig: ptr EGLint): EGLBoolean {.eglImport.}
  ## Return a list of all EGL frame buffer configurations for a display.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## configs
  ##   Returns a list of configs.
  ## configSize
  ##   Specifies the size of the list of configs.
  ## numConfig
  ##   Returns the number of configs returned.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` on failure.
  ##
  ## `configs` and `numConfig` are not modified when `EGL_FALSE` is returned.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_PARAMETER` if `numConfig` is `nil`.


proc eglGetCurrentDisplay*(): EGLDisplay {.eglImport.}
  ## Return the display for the current EGL rendering context.
  ##
  ## result
  ##   The current EGL display connection.


proc eglGetCurrentSurface*(readdraw: EGLint): EGLSurface {.eglImport.}
  ## Return the read or draw surface for the current EGL rendering context.
  ##
  ## readdraw
  ##   Specifies whether the EGL read or draw surface is to be returned.
  ## result
  ##   The read or draw surface attached to the current EGL rendering context.


proc eglGetDisplay*(nativeDisplay: EGLNativeDisplayType): EGLDisplay {.eglImport.}
  ## Return an EGL display connection.
  ##
  ## nativeDisplay
  ##   Specifies the display to connect to. `EGL_DEFAULT_DISPLAY` indicates the
  ##   default display.
  ## result
  ##   The display connection, or `EGL_NO_DISPLAY` if no display connection
  ##   matching `nativeDisplay` is available.
  ##
  ## No error is generated.


proc eglGetError*(): EGLint {.eglImport.}
  ## Return error information.
  ##
  ## result
  ##   - `EGL_SUCCESS`: The last function succeeded without error.
  ##   - `EGL_NOT_INITIALIZED`: EGL is not initialized, or could not be
  ##     initialized, for the specified EGL display connection.
  ##   - `EGL_BAD_ACCESS`: EGL cannot access a requested resource (for example a
  ##     context is bound in another thread).
  ##   - `EGL_BAD_ALLOC`: EGL failed to allocate resources for the requested
  ##     operation.
  ##   - `EGL_BAD_ATTRIBUTE`: An unrecognized attribute or attribute value was
  ##     passed in the attribute list.
  ##   - `EGL_BAD_CONTEXT`: An EGLContext argument does not name a valid EGL
  ##     rendering context.
  ##   - `EGL_BAD_CONFIG`: An EGLConfig argument does not name a valid EGL frame
  ##     buffer configuration.
  ##   - `EGL_BAD_CURRENT_SURFACE`: The current surface of the calling thread is
  ##     a window, pixel buffer or pixmap that is no longer valid.
  ##   - `EGL_BAD_DISPLAY`: An EGLDisplay argument does not name a valid EGL
  ##     display connection.
  ##   - `EGL_BAD_SURFACE`: An EGLSurface argument does not name a valid surface
  ##     (window, pixel buffer or pixmap) configured for GL rendering.
  ##   - `EGL_BAD_MATCH`: Arguments are inconsistent (for example, a valid
  ##     context requires buffers not supplied by a valid surface).
  ##   - `EGL_BAD_PARAMETER`: One or more argument values are invalid.
  ##   - `EGL_BAD_NATIVE_PIXMAP`: A NativePixmapType argument does not refer to
  ##     a valid native pixmap.
  ##   - `EGL_BAD_NATIVE_WINDOW`: A NativeWindowType argument does not refer to
  ##     a valid native window.
  ##   - `EGL_CONTEXT_LOST`: A power management event has occurred. The
  ##     application must destroy all contexts and reinitialise OpenGL ES state
  ##     and objects to continue rendering.
  ##
  ## A call to eglGetError sets the error to `EGL_SUCCESS`.


proc eglGetProcAddress*(procname: cstring): EGLMustCastToProperProcType
  {.eglImport.}
  ## Return a GL or an EGL extension function.
  ##
  ## procname
  ##   Specifies the name of the function to return.
  ## result
  ##   The address of the extension function named by `procname`.


proc eglInitialize*(display: EGLDisplay; major: ptr EGLint; minor: ptr EGLint):
  EGLBoolean {.eglImport.}
  ## Initialize an EGL display connection.
  ##
  ## display
  ##   Specifies the EGL display connection to initialize.
  ## major
  ##   Returns the major version number of the EGL implementation. May be `nil`.
  ## minor
  ##   Returns the minor version number of the EGL implementation. May be `nil`.


proc eglMakeCurrent*(display: EGLDisplay; draw: EGLSurface; read: EGLSurface;
  context: EGLContext): EGLBoolean {.eglImport.}
  ## Attach an EGL rendering context to EGL surfaces.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## draw
  ##   Specifies the EGL draw surface.
  ## read
  ##   Specifies the EGL read surface.
  ## context
  ##   Specifies the EGL rendering context to be attached to the surfaces.
  ## result
  ##   `EGL_FALSE` on failure, `EGL_TRUE` otherwise. If `EGL_FALSE` is returned,
  ##   the previously current rendering context and surfaces (if any) remain
  ##   unchanged.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_SURFACE` if `draw` or `read` is not an EGL surface.
  ## - `EGL_BAD_CONTEXT` if `context` is not an EGL rendering context.
  ## - `EGL_BAD_MATCH` if `draw` or `read` are not compatible with `context`, or
  ##   if `context` is set to `EGL_NO_CONTEXT` and `draw` or `read` are not set
  ##   to `EGL_NO_SURFACE`, or if `draw` or `read` are set to `EGL_NO_SURFACE`
  ##   and `context` is not set to `EGL_NO_CONTEXT`.
  ## - `EGL_BAD_ACCESS` if `context` is current to some other thread.
  ## - `EGL_BAD_NATIVE_PIXMAP` if a native pixmap underlying either `draw` or
  ##   `read` is no longer valid.
  ## - `EGL_BAD_NATIVE_WINDOW` if a native window underlying either `draw` or
  ##   `read` is no longer valid.
  ## - `EGL_BAD_CURRENT_SURFACE` if the previous context has unflushed commands
  ##   and the previous surface is no longer valid.
  ## - `EGL_BAD_ALLOC` if allocation of ancillary buffers for `draw` or `read`
  ##   were delayed until `eglMakeCurrent` is called, and there are not enough
  ##   resources to allocate them.
  ## - `EGL_CONTEXT_LOST` if a power management event has occurred. The
  ##   application must destroy all contexts and reinitialise OpenGL ES state
  ##   and objects to continue rendering.


proc eglQueryContext*(display: EGLDisplay; context: EGLContext;
  attribute: EGLint; value: ptr EGLint): EGLBoolean {.eglImport.}
  ## Return EGL rendering context information.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## context
  ##   Specifies the EGL rendering context to query.
  ## attribute
  ##   Specifies the EGL rendering context attribute to be returned.
  ## value
  ##   Returns the requested value.
  ## result
  ##   `EGL_FALSE` on failure, `EGL_TRUE` otherwise. `value` is not modified
  ##   when `EGL_FALSE` is returned.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONTEXT` if `context` is not an EGL rendering context.
  ## - `EGL_BAD_ATTRIBUTE` if `attribute` is not a valid context attribute.


proc eglQueryString*(display: EGLDisplay; name: EGLint): cstring
  {.eglImport.}
  ## Return a string describing an EGL display connection.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## name
  ##   Specifies a symbolic constant, one of `EGL_CLIENT_APIS`, `EGL_VENDOR`,
  ##   `EGL_VERSION`, or `EGL_EXTENSIONS`.
  ## result
  ##   `nil` is returned on failure.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_PARAMETER` if `name` is not an accepted value.


proc eglQuerySurface*(display: EGLDisplay; surface: EGLSurface;
  attribute: EGLint; value: ptr EGLint): EGLBoolean {.eglImport.}
  ## Return EGL surface information.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL surface to query.
  ## attribute
  ##   Specifies the EGL surface attribute to be returned.
  ## value
  ##   Returns the requested value.
  ## result
  ##   `EGL_FALSE` on failure, `EGL_TRUE` otherwise. `value` is not modified
  ##   when `EGL_FALSE` is returned.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_SURFACE` if `surface` is not an EGL surface.
  ## - `EGL_BAD_ATTRIBUTE` if `attribute` is not a valid surface attribute.


proc eglSwapBuffers*(display: EGLDisplay; surface: EGLSurface): EGLBoolean
  {.eglImport.}
  ## Post EGL surface color buffer to a native window.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL drawing surface whose buffers are to be swapped.
  ## result
  ##   `EGL_FALSE` if swapping of the buffers fails, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_SURFACE` if `surface` is not an EGL drawing surface.
  ## - `EGL_CONTEXT_LOST` if a power management event has occurred. The
  ##   application must destroy all contexts and reinitialise OpenGL ES state
  ##   and objects to continue rendering.


proc eglTerminate*(display: EGLDisplay): EGLBoolean {.eglImport.}
  ## Terminate an EGL display connection.
  ##
  ## display
  ##   Specifies the EGL display connection to terminate.
  ## result
  ##   `EGL_FALSE` on failure, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not an EGL display connection.


proc eglWaitGL*(): EGLBoolean {.eglImport.}
  ## Complete GL execution prior to subsequent native rendering calls.
  ##
  ## result
  ##   `EGL_FALSE` on failure, `EGL_TRUE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_CURRENT_SURFACE` if the surface associated with the current
  ##   context has a native window or pixmap, and that window or pixmap is no
  ##   longer valid.


proc eglWaitNative*(engine: EGLint): EGLBoolean {.eglImport.}
  ## Complete native execution prior to subsequent GL rendering calls.
  ##
  ## engine
  ##   Specifies a particular marking engine to be waited on. Must be
  ##   `EGL_CORE_NATIVE_ENGINE`.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_PARAMETER` if `engine` is not a recognized marking engine.
  ## - `EGL_BAD_CURRENT_SURFACE` if the surface associated with the current
  ##   context has a native window or pixmap, and that window or pixmap is no
  ##   longer valid.


# EGL 1.1 ######################################################################

const
  EGL_BACK_BUFFER* = 0x00003084
  EGL_BIND_TO_TEXTURE_RGB* = 0x00003039
  EGL_BIND_TO_TEXTURE_RGBA* = 0x0000303A
  EGL_CONTEXT_LOST* = 0x0000300E
  EGL_MIN_SWAP_INTERVAL* = 0x0000303B
  EGL_MAX_SWAP_INTERVAL* = 0x0000303C
  EGL_MIPMAP_TEXTURE* = 0x00003082
  EGL_MIPMAP_LEVEL* = 0x00003083
  EGL_NO_TEXTURE* = 0x0000305C
  EGL_TEXTURE_2D* = 0x0000305F
  EGL_TEXTURE_FORMAT* = 0x00003080
  EGL_TEXTURE_RGB* = 0x0000305D
  EGL_TEXTURE_RGBA* = 0x0000305E
  EGL_TEXTURE_TARGET* = 0x00003081


proc eglBindTexImage*(display: EGLDisplay; surface: EGLSurface; buffer: EGLint):
  EGLBoolean {.eglImport.}
  ## Defines a two-dimensional texture image.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL surface.
  ## buffer
  ##   Specifies the texture image data.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_ACCESS` if buffer is already bound to a texture.
  ## - `EGL_BAD_MATCH` if the surface attribute
  ##   `EGL_TEXTURE_FORMAT` is set to `EGL_NO_TEXTURE`.
  ## - `EGL_BAD_MATCH` if buffer is not a valid buffer (currently only
  ##   `EGL_BACK_BUFFER` may be specified).
  ## - `EGL_BAD_SURFACE` if surface is not an EGL surface, or is not a pbuffer
  ##   surface supporting texture binding.


proc eglReleaseTexImage*(display: EGLDisplay; surface: EGLSurface;
  buffer: EGLint): EGLBoolean {.eglImport.}
  ## Releases a color buffer that is being used as a texture.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL surface.
  ## buffer
  ##   Specifies the texture image data.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_MATCH` if the surface attribute `EGL_TEXTURE_FORMAT` is set to
  ##   `EGL_NO_TEXTURE`.
  ## - `EGL_BAD_MATCH` if buffer is not a valid buffer (currently only
  ##   `EGL_BACK_BUFFER` may be specified).
  ## - `EGL_BAD_SURFACE` if surface is not an EGL surface, or is not a bound
  ##   pbuffer surface.


proc eglSurfaceAttrib*(display: EGLDisplay; surface: EGLSurface;
  attribute: EGLint; value: EGLint): EGLBoolean {.eglImport.}
  ## Set an EGL surface attribute.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## surface
  ##   Specifies the EGL surface.
  ## attribute
  ##   Specifies the EGL surface attribute to set.
  ## value
  ##   Specifies the attributes required value.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if display is not an EGL display connection.
  ## - `EGL_BAD_MATCH` if attribute is `EGL_MULTISAMPLE_RESOLVE`, value is
  ##   `EGL_MULTISAMPLE_RESOLVE_BOX`, and the `EGL_SURFACE_TYPE` attribute of
  ##   the `EGLConfig <#EGLConfig>`_ used to create surface does not contain
  ##   `EGL_MULTISAMPLE_RESOLVE_BOX_BIT`.
  ## - `EGL_BAD_MATCH` if attribute is `EGL_SWAP_BEHAVIOR`, value is
  ##   `EGL_BUFFER_PRESERVED`, and the `EGL_SURFACE_TYPE` attribute of the
  ##   `EGLConfig <#EGLConfig>`_ used to create surface does not contain
  ##   `EGL_SWAP_BEHAVIOR_PRESERVED_BIT`.
  ## - `EGL_NOT_INITIALIZED` if display has not been initialized.
  ## - `EGL_BAD_SURFACE` if surface is not an EGL surface.
  ## - `EGL_BAD_ATTRIBUTE` if attribute is not a valid surface attribute.


proc eglSwapInterval*(display: EGLDisplay; interval: EGLint): EGLBoolean
  {.eglImport.}
  ## Specifies the minimum number of video frame periods per buffer swap for the
  ## window associated with the current context.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## interval
  ##   Specifies the minimum number of video frames that are displayed before a
  ##   buffer swap will occur.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_CONTEXT` if there is no current context on the calling thread.
  ## - `EGL_BAD_SURFACE` if there is no surface bound to the current context.


# EGL 1.2 ######################################################################

type
  EGLenum* = cuint
  EGLClientBuffer* = pointer


const
  EGL_ALPHA_FORMAT* = 0x00003088
  EGL_ALPHA_FORMAT_NONPRE* = 0x0000308B
  EGL_ALPHA_FORMAT_PRE* = 0x0000308C
  EGL_ALPHA_MASK_SIZE* = 0x0000303E
  EGL_BUFFER_PRESERVED* = 0x00003094
  EGL_BUFFER_DESTROYED* = 0x00003095
  EGL_CLIENT_APIS* = 0x0000308D
  EGL_COLORSPACE* = 0x00003087
  EGL_COLORSPACE_sRGB* = 0x00003089
  EGL_COLORSPACE_LINEAR* = 0x0000308A
  EGL_COLOR_BUFFER_TYPE* = 0x0000303F
  EGL_CONTEXT_CLIENT_TYPE* = 0x00003097
  EGL_DISPLAY_SCALING* = 10000
  EGL_HORIZONTAL_RESOLUTION* = 0x00003090
  EGL_LUMINANCE_BUFFER* = 0x0000308F
  EGL_LUMINANCE_SIZE* = 0x0000303D
  EGL_OPENGL_ES_BIT* = 0x00000001
  EGL_OPENVG_BIT* = 0x00000002
  EGL_OPENGL_ES_API* = 0x000030A0
  EGL_OPENVG_API* = 0x000030A1
  EGL_OPENVG_IMAGE* = 0x00003096
  EGL_PIXEL_ASPECT_RATIO* = 0x00003092
  EGL_RENDERABLE_TYPE* = 0x00003040
  EGL_RENDER_BUFFER* = 0x00003086
  EGL_RGB_BUFFER* = 0x0000308E
  EGL_SINGLE_BUFFER* = 0x00003085
  EGL_SWAP_BEHAVIOR* = 0x00003093
  EGL_UNKNOWN* = -1
  EGL_VERTICAL_RESOLUTION* = 0x00003091


proc eglBindAPI*(api: EGLenum): EGLBoolean {.eglImport.}
  ## Set the current rendering API.
  ##
  ## api
  ##   Specifies the client API to bind, one of `EGL_OPENGL_API`,
  ##   `EGL_OPENGL_ES_API`, or `EGL_OPENVG_API`.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_PARAMETER` if api is not one of the accepted tokens, or if the
  ##   specified client API is not supported by the EGL implementation.


proc eglQueryAPI*(): EGLenum {.eglImport.}
  ## Query the current rendering API.
  ##
  ## result
  ##   One of the valid API parameters to `eglBindAPI <#eglBindAPI>`_, or
  ##   `EGL_NONE`.


proc eglCreatePbufferFromClientBuffer*(display: EGLDisplay; buftype: EGLenum;
  buffer: EGLClientBuffer; config: EGLConfig; attribList: ptr EGLint):
  EGLSurface {.eglImport.}
  ## Create a new EGL pixel buffer surface bound to an OpenVG image.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## buftype
  ##   Specifies the type of client API buffer to be bound. Must be
  ##   `EGL_OPENVG_IMAGE`, corresponding to an OpenVG VGImage buffer.
  ## buffer
  ##   Specifies the OpenVG VGImage handle of the buffer to be bound.
  ## config
  ##   Specifies the EGL frame buffer configuration that defines the frame
  ##   buffer resource available to the surface.
  ## attribList
  ##   Specifies pixel buffer surface attributes. May be NULL or empty (first
  ##   attribute is `EGL_NONE`).
  ## result
  ##   `EGL_NO_SURFACE` is returned if creation of the context fails.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY if `display` is not an EGL display connection.
  ## - `EGL_NOT_INITIALIZED` if `display` has not been initialized.
  ## - `EGL_BAD_CONFIG` if `config` is not an EGL frame buffer configuration.
  ## - `EGL_BAD_PARAMETER` if `buftype` is not `EGL_OPENVG_IMAGE`, or if buffer is
  ##   not a valid handle to a VGImage object in the currently bound OpenVG
  ##   context.
  ## - `EGL_BAD_ACCESS` if there is no current OpenVG context, or if `buffer` is
  ##   already bound to another pixel buffer or in use by OpenVG.
  ## - `EGL_BAD_ALLOC` if there are not enough resources to allocate the new
  ##   surface.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains an invalid pixel buffer
  ##   attribute or if an attribute value is not recognized or out of range.
  ## - `EGL_BAD_ATTRIBUTE` if `attribList` contains any of the attributes
  ##   `EGL_MIPMAP_TEXTURE`, `EGL_TEXTURE_FORMAT`, or `EGL_TEXTURE_TARGET`, and
  ##   config does not support OpenGL ES rendering (e.g. the EGL version is 1.2
  ##   or later, and the `EGL_RENDERABLE_TYPE` attribute of `config` does not
  ##   include at least one of `EGL_OPENGL_ES_BIT` or `EGL_OPENGL_ES2_BIT`).
  ## - `EGL_BAD_MATCH` if `config` does not support rendering to pixel buffers
  ##   (the `EGL_SURFACE_TYPE` attribute does not contain `EGL_PBUFFER_BIT`).
  ## - `EGL_BAD_MATCH` if the buffers contained in `buffer` do not match the bit
  ##   depths for those buffers specified by `config`.
  ## - `EGL_BAD_MATCH` if the `EGL_TEXTURE_FORMAT` attribute is not
  ##   `EGL_NO_TEXTURE`, and `EGL_WIDTH` and/or `EGL_HEIGHT` specify an invalid
  ##   size (e.g., the texture size is not a power of 2, and the underlying
  ##   OpenGL ES implementation does not support non-power-of-two textures).
  ## - `EGL_BAD_MATCH` if the `EGL_TEXTURE_FORMAT` attribute is
  ##   `EGL_NO_TEXTURE`, and `EGL_TEXTURE_TARGET` is something other than
  ##   `EGL_NO_TEXTURE`; or, `EGL_TEXTURE_FORMAT` is something other than
  ##   `EGL_NO_TEXTURE`, and `EGL_TEXTURE_TARGET` is `EGL_NO_TEXTURE`.
  ## - `EGL_BAD_MATCH` if the implementation has additional constraints on which
  ##   types of client API buffers may be bound to pixel buffer surfaces. For
  ##   example, it is possible that the OpenVG implementation might not support
  ##   a VGImage being bound to a pixel buffer which will be used as a mipmapped
  ##   OpenGL ES texture (e.g. whose `EGL_MIPMAP_TEXTURE` attribute is
  ##   `EGL_TRUE`). Any such constraints should be documented by the
  ##   implementation release notes.


proc eglReleaseThread*(): EGLBoolean {.eglImport.}
  ## Release EGL per-thread state.
  ##
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.


proc eglWaitClient*(): EGLBoolean {.eglImport.}
  ## Complete client API execution prior to subsequent native rendering calls.
  ##
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_CURRENT_SURFACE` if the surface associated with the current context has a native window or pixmap, and that window or pixmap is no longer valid.


# EGL 1.3 ######################################################################

const
  EGL_CONFORMANT* = 0x00003042
  EGL_CONTEXT_CLIENT_VERSION* = 0x00003098
  EGL_MATCH_NATIVE_PIXMAP* = 0x00003041
  EGL_OPENGL_ES2_BIT* = 0x00000004
  EGL_VG_ALPHA_FORMAT* = 0x00003088
  EGL_VG_ALPHA_FORMAT_NONPRE* = 0x0000308B
  EGL_VG_ALPHA_FORMAT_PRE* = 0x0000308C
  EGL_VG_ALPHA_FORMAT_PRE_BIT* = 0x00000040
  EGL_VG_COLORSPACE* = 0x00003087
  EGL_VG_COLORSPACE_sRGB* = 0x00003089
  EGL_VG_COLORSPACE_LINEAR* = 0x0000308A
  EGL_VG_COLORSPACE_LINEAR_BIT* = 0x00000020


# EGL 1.4 ######################################################################

when compiles(EGLNativeDisplayType(nil)):
  const EGL_DEFAULT_DISPLAY* = EGLNativeDisplayType(nil)
else:
  const EGL_DEFAULT_DISPLAY* = EGLNativeDisplayType(0)

const
  EGL_MULTISAMPLE_RESOLVE_BOX_BIT* = 0x00000200
  EGL_MULTISAMPLE_RESOLVE* = 0x00003099
  EGL_MULTISAMPLE_RESOLVE_DEFAULT* = 0x0000309A
  EGL_MULTISAMPLE_RESOLVE_BOX* = 0x0000309B
  EGL_OPENGL_API* = 0x000030A2
  EGL_OPENGL_BIT* = 0x00000008
  EGL_SWAP_BEHAVIOR_PRESERVED_BIT* = 0x00000400


proc eglGetCurrentContext*(): EGLContext {.eglImport.}
  ## Return the current EGL rendering context.
  ##
  ## result
  ##   The current context, or `EGL_NO_CONTEXT` if no context is current.


# EGL 1.5 (as of 2014/08/27) ###################################################

type
  EGLSync* = pointer
  EGLAttrib* = csize
  EGLTime* = culonglong
  EGLImage* = pointer


const
  EGL_CONTEXT_MAJOR_VERSION* = 0x00003098
  EGL_CONTEXT_MINOR_VERSION* = 0x000030FB
  EGL_CONTEXT_OPENGL_PROFILE_MASK* = 0x000030FD
  EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY* = 0x000031BD
  EGL_NO_RESET_NOTIFICATION* = 0x000031BE
  EGL_LOSE_CONTEXT_ON_RESET* = 0x000031BF
  EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT* = 0x00000001
  EGL_CONTEXT_OPENGL_COMPATIBILITY_PROFILE_BIT* = 0x00000002
  EGL_CONTEXT_OPENGL_DEBUG* = 0x000031B0
  EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE* = 0x000031B1
  EGL_CONTEXT_OPENGL_ROBUST_ACCESS* = 0x000031B2
  EGL_OPENGL_ES3_BIT* = 0x00000040
  EGL_CL_EVENT_HANDLE* = 0x0000309C
  EGL_SYNC_CL_EVENT* = 0x000030FE
  EGL_SYNC_CL_EVENT_COMPLETE* = 0x000030FF
  EGL_SYNC_PRIOR_COMMANDS_COMPLETE* = 0x000030F0
  EGL_SYNC_TYPE* = 0x000030F7
  EGL_SYNC_STATUS* = 0x000030F1
  EGL_SYNC_CONDITION* = 0x000030F8
  EGL_SIGNALED* = 0x000030F2
  EGL_UNSIGNALED* = 0x000030F3
  EGL_SYNC_FLUSH_COMMANDS_BIT* = 0x00000001
  EGL_FOREVER* = 0xFFFFFFFFFFFFFFFF'i64
  EGL_TIMEOUT_EXPIRED* = 0x000030F5
  EGL_CONDITION_SATISFIED* = 0x000030F6
  EGL_NO_SYNC* = (cast[EGLSync](0))
  EGL_SYNC_FENCE* = 0x000030F9
  EGL_GL_COLORSPACE* = 0x0000309D
  EGL_GL_COLORSPACE_SRGB* = 0x00003089
  EGL_GL_COLORSPACE_LINEAR* = 0x0000308A
  EGL_GL_RENDERBUFFER* = 0x000030B9
  EGL_GL_TEXTURE_2D* = 0x000030B1
  EGL_GL_TEXTURE_LEVEL* = 0x000030BC
  EGL_GL_TEXTURE_3D* = 0x000030B2
  EGL_GL_TEXTURE_ZOFFSET* = 0x000030BD
  EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_X* = 0x000030B3
  EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_X* = 0x000030B4
  EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Y* = 0x000030B5
  EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y* = 0x000030B6
  EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Z* = 0x000030B7
  EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z* = 0x000030B8
  EGL_IMAGE_PRESERVED* = 0x000030D2
  EGL_NO_IMAGE* = (cast[EGLImage](0))


proc eglCreateSync*(display: EGLDisplay; syncType: EGLenum;
  attribList: ptr EGLAttrib): EGLSync {.eglImport.}
  ## Create a sync object of the specified type.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## syncType
  ##   The type of sync object to create.
  ## attribList
  ##   Specifies attributes for the sync object.
  ## result
  ##   The sync object.


proc eglDestroySync*(display: EGLDisplay; sync: EGLSync): EGLBoolean
  {.eglImport.}
  ## Destroy an existing sync object.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## sync
  ##   The sync object to destroy.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ##   - `EGL_BAD_PARAMETER` if `sync` is not a valid sync object for `display`.


proc eglClientWaitSync*(display: EGLDisplay; sync: EGLSync; flags: EGLint;
  timeout: EGLTime): EGLint {.eglImport.}
  ## Blocks the calling thread until the specified sync object signaled or
  ## timed out.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## sync
  ##   The sync object to wait for.
  ## flags
  ##   Optional `EGL_SYNC_FLUSH_COMMANDS_BIT` to perform a flush when the sync
  ##   object is unsignaled. If no context is current for the bound API, the
  ##   `EGL_SYNC_FLUSH_COMMANDS_BIT` bit is ignored.
  ## timeout
  ##   Maximum number of nanoseconds to wait, or `EGL_FOREVER`.
  ## result
  ##   - `EGL_TIMEOUT_EXPIRED` if the time out period expired before the sync
  ##   object was signaled
  ##   - `EGL_CONDITION_SATISFIED` if the sync object was signaled
  ##   - `EGL_FALSE` on error.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_PARAMETER` if `sync` is not a valid sync object for `display`.


proc eglGetSyncAttrib*(display: EGLDisplay; sync: EGLSync; attribute: EGLint;
  value: ptr EGLAttrib): EGLBoolean {.eglImport.}
  ## Query attributes of a sync object.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## sync
  ##   The sync object to query.
  ## attribute
  ##   The attribute to query. These depend on the type of sync object being
  ##   queried. See the official EGL documentation for details.
  ## value
  ##   Will contain the queried value on success.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_PARAMETER` if `sync` is not a valid sync object.
  ## - `EGL_BAD_ATTRIBUTE` if `attribute` is not one of the available attributes.
  ## - `EGL_BAD_MATCH` if `attribute` is not supported for the type of sync
  ##   object passed in `sync`.


proc eglCreateImage*(display: EGLDisplay; context: EGLContext; target: EGLenum;
  buffer: EGLClientBuffer; attribList: ptr EGLAttrib): EGLImage {.eglImport.}
  ## Create an EGLImage from an existing image resource.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## context
  ##   Specifies the EGL client API context.
  ## target
  ##   The type of resource being used as the image source.
  ## buffer
  ##   The name or handle of the resource to be used as the image source.
  ## attribList
  ##   Specifies a list of attributes used to select sub-sections of `buffer`,
  ##   such as mipmap levels for OpenGL ES texture map resources, as well as
  ##   behavioral options, such as whether to preserve pixel data during
  ##   creation. May be `nil`.
  ## result
  ##   The image object, or `EGL_NO_IMAGE` on failure.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not a valid display object.
  ## - `EGL_BAD_CONTEXT` if `context` is neither a valid context on the display,
  ##   nor `EGL_NO_CONTEXT`
  ## - `EGL_BAD_DISPLAY` if `target` is `EGL_GL_TEXTURE_2D`,
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*`, `EGL_GL_RENDERBUFFER` or
  ##   `EGL_GL_TEXTURE_3D`, and `display` is not a valid display.
  ## - `EGL_BAD_CONTEXT` if target is `EGL_GL_TEXTURE_2D`,
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*`, `EGL_GL_RENDERBUFFER` or
  ##   `EGL_GL_TEXTURE_3D`, and `context` is not a valid context.
  ## - `EGL_BAD_MATCH` if `target` is `EGL_GL_TEXTURE_2D`,
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*`, `EGL_GL_RENDERBUFFER` or
  ##   `EGL_GL_TEXTURE_3D`, and `context` is not a valid GL context, or does not
  ##   match the `display`.
  ## - `EGL_BAD_PARAMETER` if `target` is `EGL_GL_TEXTURE_2D`,
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*` or `EGL_GL_TEXTURE_3D` and buffer is not the
  ##   name of a texture object of type `target`.
  ## - `EGL_BAD_PARAMETER` if `target` is `EGL_GL_RENDERBUFFER` and `buffer` is
  ##   not the name of a renderbuffer object, or if `buffer` is the name of a
  ##   multisampled renderbuffer object.
  ## - `EGL_BAD_PARAMETER` if `EGL_GL_TEXTURE_LEVEL` is nonzero, `target` is
  ##   `EGL_GL_TEXTURE_2D`, `EGL_GL_TEXTURE_CUBE_MAP_*` or `EGL_GL_TEXTURE_3D`,
  ##   and `buffer` is not the name of a complete GL texture object.
  ## - `EGL_BAD_PARAMETER` if `EGL_GL_TEXTURE_LEVEL` is `0`, `target` is
  ##   `EGL_GL_TEXTURE_2D`, `EGL_GL_TEXTURE_CUBE_MAP_*` or `EGL_GL_TEXTURE_3D`,
  ##   `buffer` is the name of an incomplete GL texture object, and any mipmap
  ##   levels other than mipmap level 0 are specified.
  ## - `EGL_BAD_PARAMETER` if `EGL_GL_TEXTURE_LEVEL` is `0`, `target` is
  ##   `EGL_GL_TEXTURE_2D` or `EGL_GL_TEXTURE_3D`, `buffer` is not the name of a
  ##   complete GL texture object, and mipmap level 0 is not specified.
  ## - `EGL_BAD_PARAMETER` if `EGL_GL_TEXTURE_LEVEL` is `0`, `target` is
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*`, `buffer` is not the name of a complete GL
  ##   texture object, and one or more faces do not have mipmap level 0
  ##   specified.
  ## - `EGL_BAD_PARAMETER` if `target` is `EGL_GL_TEXTURE_2D`,
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*`, `EGL_GL_RENDERBUFFER` or `EGL_GL_TEXTURE_3D`
  ##   and `buffer` refers to the default GL texture object (0) for the
  ##   corresponding GL target.
  ## - `EGL_BAD_MATCH` if `target` is `EGL_GL_TEXTURE_2D`,
  ##   `EGL_GL_TEXTURE_CUBE_MAP_*`, or `EGL_GL_TEXTURE_3D`, and the value
  ##   specified in `attribList` for `EGL_GL_TEXTURE_LEVEL` is not a valid
  ##   mipmap level for the specified GL texture object `buffer`.
  ## - `EGL_BAD_PARAMETER` if `target` is `EGL_GL_TEXTURE_3D`, and the value
  ##   specified in `attribList` for `EGL_GL_TEXTURE_ZOFFSET` exceeds the depth
  ##   of the specified mipmap level-of-detail in `buffer`.
  ## - `EGL_BAD_PARAMETER` if an attribute specified in `attribList` is not one
  ##   of the supported attributes.
  ## - `EGL_BAD_MATCH` if an attribute specified in `attribList` is not a
  ##   valid attribute for `target`.
  ## - `EGL_BAD_ACCESS` if the resource specified by `display`, `context`,
  ##   `target`, `buffer` and `attribList` has an off-screen buffer bound to it
  ##   (e.g., by a previous call to `eglBindTexImage <#eglBindTexImage>`_).
  ## - `EGL_BAD_ACCESS` if the resource specified by `display`, `context`,
  ##   `target`, `buffer` and `attribList` is bound to an off-screen buffer
  ##   (e.g., by a previous call to
  ##   `eglCreatePbufferFromClientBuffer <#eglCreatePbufferFromClientBuffer>`_)
  ## - `EGL_BAD_ACCESS` if the resource specified by `display`, `context`,
  ##   `target`, `buffer` and `attribList` is itself an `EGLImage <#EGLImage>`_
  ##   sibling.
  ## - `EGL_BAD_ALLOC` if f insufficient memory is available to complete the
  ##   specified operation.
  ## - `EGL_BAD_ACCESS` if the value specified in `attribList` for
  ##   `EGL_IMAGE_PRESERVED` is `EGL_TRUE`, and an `EGLImage <#EGLImage>`_
  ##   handle cannot be created from the specified resource such that the pixel
  ##   data values in `buffer` are preserved.


proc eglDestroyImage*(display: EGLDisplay; image: EGLImage): EGLBoolean
  {.eglImport.}
  ## Destroy an image object.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## image
  ##   The image to destroy.
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_DISPLAY` if `display` is not the handle of a valid
  ##   `EGLDisplay <#EGLDisplay>`_ object.
  ## - `EGL_BAD_PARAMETER` if `image` is not a valid `EGLImage <#EGLImage>`_
  ##   object created with respect to `display`.


proc eglGetPlatformDisplay*(platform: EGLenum; nativeDisplay: pointer;
  attribList: ptr EGLAttrib): EGLDisplay {.eglImport.}
  ## Obtain a native platform display.
  ##
  ## platform
  ##   Specifies the native platform.
  ## nativeDisplay
  ##   Handle to a native display, i.e. pointer to an X11 display.
  ## attribList
  ##   Specifies the list of desired display attributes
  ## result
  ##   The display, or `EGL_NO_DISPLAY` if no matching display is available, or
  ##   on error.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_PARAMETER` if `platform` has an invalid value.


proc eglCreatePlatformWindowSurface*(display: EGLDisplay; config: EGLConfig;
  nativeWindow: pointer; attribList: ptr EGLAttrib): EGLSurface {.eglImport.}
  ## Create an onscreen EGLSurface.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the color and ancillary buffer configuration for the surface.
  ## nativeWindow
  ##   A native window that must belong to the same platform as `display`.
  ## attribList
  ##   Specifies the attributes for the window.
  ## result
  ##   A handle to the created surface, or `EGL_NO_SURFACE` on error.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_MATCH` if the pixel format of `nativeWindow` does not correspond
  ##   to the format, type, and size of the color buffers required by `config`.
  ## - `EGL_BAD_MATCH` if `config` does not support rendering to windows (the
  ##   `EGL_SURFACE_TYPE` attribute does not contain `EGL_WINDOW_BIT`).
  ## - `EGL_BAD_MATCH` if `config` does not support the OpenVG colorspace or
  ##   alpha format attributes specified in `attribList` (as defined for
  ##   `eglCreatePlatformWindowSurface <#eglCreatePlatformWindowSurface>`_).
  ## - `EGL_BAD_CONFIG` if `config` is not a valid `EGLConfig <#EGLConfig>`_.
  ## - `EGL_BAD_NATIVE_WINDOW` if `nativeWindow` is not a valid native window
  ##   handle
  ## - `EGL_BAD_ALLOC` if there is already an `EGLSurface <#EGLSurface>`_
  ##   associated with `nativeWindow` (as a result of a previous call to
  ##   `eglCreatePlatformWindowSurface`).
  ## - `EGL_BAD_ALLOC` if the implementation cannot allocate resources for the
  ##   new EGL window.


proc eglCreatePlatformPixmapSurface*(display: EGLDisplay; config: EGLConfig;
  nativePixmap: pointer; attribList: ptr EGLAttrib): EGLSurface {.eglImport.}
  ## Create an offscreen EGLSurface.
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## config
  ##   Specifies the color and ancillary buffer configuration for the surface.
  ## nativePixmap
  ##   A native pixmap that must belong to the same platform as `display`.
  ## attribList
  ##   Specifies the attributes for the pixmap.
  ## result
  ##   A handle to the created surface, or `EGL_NO_SURFACE` on error.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_MATCH` if the attributes of `nativePixmap` do not correspond to
  ##   `config`.
  ## - `EGL_BAD_MATCH` if `config` does not support rendering to pixmaps (the
  ##   `EGL_SURFACE_TYPE` attribute does not contain `EGL_PIXMAP_BIT`).
  ## - `EGL_BAD_MATCH` if `config` does not support the colorspace or alpha
  ##   format attributes specified in `attribList` (as defined for
  ##   `eglCreatePlatformWindowSurface <#eglCreatePlatformWindowSurface>`_).
  ## - `EGL_BAD_CONFIG` if `config` is not a valid `EGLConfig <#EGLConfig>`_.
  ## - `EGL_BAD_NATIVE_PIXMAP` if `pixmap` is not a valid native pixmap handle.
  ## - `EGL_BAD_ALLOC` if there is already an `EGLSurface <#EGLSurface>`_
  ##   associated with `nativePixmap` (as a result of a previous call to
  ##   `eglCreatePlatformPixmapSurface`).
  ## - `EGL_BAD_ALLOC` if the implementation cannot allocate resources for the
  ##   new EGL pixmap.


proc eglWaitSync*(display: EGLDisplay; sync: EGLSync; flags: EGLint): EGLBoolean
  {.eglImport.}
  ## Check whether a sync object is signaled (without blocking the application).
  ##
  ## display
  ##   Specifies the EGL display connection.
  ## sync
  ##   The sync object to check.
  ## flags
  ##   Must be `0`.
  ##
  ## result
  ##   `EGL_TRUE` on success, `EGL_FALSE` otherwise.
  ##
  ## The following error codes may be generated:
  ## - `EGL_BAD_MATCH` if the current context for the currently bound client API
  ##   does not support server waits.
  ## - `EGL_BAD_MATCH` if no context is current for the currently bound client
  ##   API (i.e., `eglGetCurrentContext <#eglGetCurrentContext>`_ returns
  ##   `EGL_NO_CONTEXT`)
  ## - `EGL_BAD_PARAMETER` if `sync` is not a valid sync object.
  ## - `EGL_BAD_PARAMETER` if `flags` is not `0`.
