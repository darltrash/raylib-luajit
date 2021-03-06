local ffi = require('ffi')

--local lib = ffi.load('libraylib.2.0.0.dylib')
local lib = ffi.load('libraylib')
ffi.cdef[[
typedef struct Vector2 {
    float x;
    float y;
} Vector2;

typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;

typedef struct Vector4 {
    float x;
    float y;
    float z;
    float w;
} Vector4;

typedef Vector4 Quaternion;

typedef struct Matrix {
    float m0, m4, m8, m12;
    float m1, m5, m9, m13;
    float m2, m6, m10, m14;
    float m3, m7, m11, m15;
} Matrix;

typedef struct Color {
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
} Color;

typedef struct Rectangle {
    float x;
    float y;
    float width;
    float height;
} Rectangle;

typedef struct Image {
    void *data;             // Image raw data
    int width;              // Image base width
    int height;             // Image base height
    int mipmaps;            // Mipmap levels, 1 by default
    int format;             // Data format (PixelFormat type)
} Image;

typedef struct Texture2D {
    unsigned int id;        // OpenGL texture id
    int width;              // Texture base width
    int height;             // Texture base height
    int mipmaps;            // Mipmap levels, 1 by default
    int format;             // Data format (PixelFormat type)
} Texture2D;

typedef Texture2D Texture;

typedef Texture2D TextureCubemap;

typedef struct RenderTexture2D {
    unsigned int id;        // OpenGL Framebuffer Object (FBO) id
    Texture2D texture;      // Color buffer attachment texture
    Texture2D depth;        // Depth buffer attachment texture
    bool depthTexture;      // Track if depth attachment is a texture or renderbuffer
} RenderTexture2D;

typedef RenderTexture2D RenderTexture;

typedef struct NPatchInfo {
    Rectangle sourceRec;   // Region in the texture
    int left;              // left border offset
    int top;               // top border offset
    int right;             // right border offset
    int bottom;            // bottom border offset
    int type;              // layout of the n-patch: 3x3, 1x3 or 3x1
} NPatchInfo;

typedef struct CharInfo {
    int value;              // Character value (Unicode)
    int offsetX;            // Character offset X when drawing
    int offsetY;            // Character offset Y when drawing
    int advanceX;           // Character advance position X
    Image image;            // Character image data
} CharInfo;

typedef struct Font {
    int baseSize;           // Base size (default chars height)
    int charsCount;         // Number of characters
    Texture2D texture;      // Characters texture atlas
    Rectangle *recs;        // Characters rectangles in texture
    CharInfo *chars;        // Characters info data
} Font;

typedef struct Camera3D {
    Vector3 position;       // Camera position
    Vector3 target;         // Camera target it looks-at
    Vector3 up;             // Camera up vector (rotation over its axis)
    float fovy;             // Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
    int type;               // Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
} Camera3D;

typedef Camera3D Camera;

typedef struct Camera2D {
    Vector2 offset;         // Camera offset (displacement from target)
    Vector2 target;         // Camera target (rotation and zoom origin)
    float rotation;         // Camera rotation in degrees
    float zoom;             // Camera zoom (scaling), should be 1.0f by default
} Camera2D;

typedef struct Mesh {
    int vertexCount;        // Number of vertices stored in arrays
    int triangleCount;      // Number of triangles stored (indexed or not)

    // Default vertex data
    float *vertices;        // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    float *texcoords;       // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    float *texcoords2;      // Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    float *normals;         // Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    float *tangents;        // Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    unsigned char *colors;  // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    unsigned short *indices;// Vertex indices (in case vertex data comes indexed)

    // Animation vertex data
    float *animVertices;    // Animated vertex positions (after bones transformations)
    float *animNormals;     // Animated normals (after bones transformations)
    int *boneIds;           // Vertex bone ids, up to 4 bones influence by vertex (skinning)
    float *boneWeights;     // Vertex bone weight, up to 4 bones influence by vertex (skinning)

    // OpenGL identifiers
    unsigned int vaoId;     // OpenGL Vertex Array Object id
    unsigned int *vboId;    // OpenGL Vertex Buffer Objects id (default vertex data)
} Mesh;

typedef struct Shader {
    unsigned int id;        
    int *locs;              
} Shader;

typedef struct MaterialMap {
    Texture2D texture;      // Material map texture
    Color color;            // Material map color
    float value;            // Material map value
} MaterialMap;

typedef struct Material {
    Shader shader;          // Material shader
    MaterialMap *maps;      // Material maps array (MAX_MATERIAL_MAPS)
    float *params;          // Material generic parameters (if required)
} Material;

typedef struct Transform {
    Vector3 translation;    // Translation
    Quaternion rotation;    // Rotation
    Vector3 scale;          // Scale
} Transform;

typedef struct BoneInfo {
    char name[32];          // Bone name
    int parent;             // Bone parent
} BoneInfo;

typedef struct Model {
    Matrix transform;       // Local transform matrix

    int meshCount;          // Number of meshes
    Mesh *meshes;           // Meshes array

    int materialCount;      // Number of materials
    Material *materials;    // Materials array
    int *meshMaterial;      // Mesh material number

    // Animation data
    int boneCount;          // Number of bones
    BoneInfo *bones;        // Bones information (skeleton)
    Transform *bindPose;    // Bones base transformation (pose)
} Model;

typedef struct ModelAnimation {
    int boneCount;          // Number of bones
    BoneInfo *bones;        // Bones information (skeleton)

    int frameCount;         // Number of animation frames
    Transform **framePoses; // Poses array by frame
} ModelAnimation;

typedef struct Ray {
    Vector3 position;       // Ray position (origin)
    Vector3 direction;      // Ray direction
} Ray;

typedef struct RayHitInfo {
    bool hit;               // Did the ray hit something?
    float distance;         // Distance to nearest hit
    Vector3 position;       // Position of nearest hit
    Vector3 normal;         // Surface normal of hit
} RayHitInfo;

typedef struct BoundingBox {
    Vector3 min;            // Minimum vertex box-corner
    Vector3 max;            // Maximum vertex box-corner
} BoundingBox;

typedef struct Wave {
    unsigned int sampleCount;       // Total number of samples
    unsigned int sampleRate;        // Frequency (samples per second)
    unsigned int sampleSize;        // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    unsigned int channels;          // Number of channels (1-mono, 2-stereo)
    void *data;                     // Buffer data pointer
} Wave;

typedef struct rAudioBuffer rAudioBuffer;

typedef struct AudioStream {
    unsigned int sampleRate;        // Frequency (samples per second)
    unsigned int sampleSize;        // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    unsigned int channels;          // Number of channels (1-mono, 2-stereo)

    rAudioBuffer *buffer;           // Pointer to internal data used by the audio system
} AudioStream;

typedef struct Sound {
    unsigned int sampleCount;       // Total number of samples
    AudioStream stream;             // Audio stream
} Sound;

typedef struct Music {
    int ctxType;                    // Type of music context (audio filetype)
    void *ctxData;                  // Audio context data, depends on type

    bool looping;                   // Music looping enable
    unsigned int sampleCount;       // Total number of samples

    AudioStream stream;             // Audio stream
} Music;

typedef struct VrDeviceInfo {
    int hResolution;                // HMD horizontal resolution in pixels
    int vResolution;                // HMD vertical resolution in pixels
    float hScreenSize;              // HMD horizontal size in meters
    float vScreenSize;              // HMD vertical size in meters
    float vScreenCenter;            // HMD screen center in meters
    float eyeToScreenDistance;      // HMD distance between eye and display in meters
    float lensSeparationDistance;   // HMD lens separation distance in meters
    float interpupillaryDistance;   // HMD IPD (distance between pupils) in meters
    float lensDistortionValues[4];  // HMD lens distortion constant parameters
    float chromaAbCorrection[4];    // HMD chromatic aberration correction parameters
} VrDeviceInfo;

void InitWindow(int width, int height, const char *title);              // Initialize window and OpenGL context
bool WindowShouldClose(void);                                           // Check if KEY_ESCAPE pressed or Close icon pressed
void CloseWindow(void);                                                 // Close window and unload OpenGL context
bool IsWindowReady(void);                                               // Check if window has been initialized successfully
bool IsWindowMinimized(void);                                           // Check if window has been minimized (or lost focus)
bool IsWindowResized(void);                                             // Check if window has been resized
bool IsWindowHidden(void);                                              // Check if window is currently hidden
bool IsWindowFullscreen(void);                                          // Check if window is currently fullscreen
void ToggleFullscreen(void);                                            // Toggle fullscreen mode (only PLATFORM_DESKTOP)
void UnhideWindow(void);                                                // Show the window
void HideWindow(void);                                                  // Hide the window
void SetWindowIcon(Image image);                                        // Set icon for window (only PLATFORM_DESKTOP)
void SetWindowTitle(const char *title);                                 // Set title for window (only PLATFORM_DESKTOP)
void SetWindowPosition(int x, int y);                                   // Set window position on screen (only PLATFORM_DESKTOP)
void SetWindowMonitor(int monitor);                                     // Set monitor for the current window (fullscreen mode)
void SetWindowMinSize(int width, int height);                           // Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
void SetWindowSize(int width, int height);                              // Set window dimensions
void *GetWindowHandle(void);                                            // Get native window handle
int GetScreenWidth(void);                                               // Get current screen width
int GetScreenHeight(void);                                              // Get current screen height
int GetMonitorCount(void);                                              // Get number of connected monitors
int GetMonitorWidth(int monitor);                                       // Get primary monitor width
int GetMonitorHeight(int monitor);                                      // Get primary monitor height
int GetMonitorPhysicalWidth(int monitor);                               // Get primary monitor physical width in millimetres
int GetMonitorPhysicalHeight(int monitor);                              // Get primary monitor physical height in millimetres
Vector2 GetWindowPosition(void);                                        // Get window position XY on monitor
const char *GetMonitorName(int monitor);                                // Get the human-readable, UTF-8 encoded name of the primary monitor
const char *GetClipboardText(void);                                     // Get clipboard text content
void SetClipboardText(const char *text);                                // Set clipboard text content
            
// Cursor-related functions         
void ShowCursor(void);                                                  // Shows cursor
void HideCursor(void);                                                  // Hides cursor
bool IsCursorHidden(void);                                              // Check if cursor is not visible
void EnableCursor(void);                                                // Enables cursor (unlock cursor)
void DisableCursor(void);                                               // Disables cursor (lock cursor)
            
// Drawing-related functions            
void ClearBackground(Color color);                                      // Set background color (framebuffer clear color)
void BeginDrawing(void);                                                // Setup canvas (framebuffer) to start drawing
void EndDrawing(void);                                                  // End canvas drawing and swap buffers (double buffering)
void BeginMode2D(Camera2D camera);                                      // Initialize 2D mode with custom camera (2D)
void EndMode2D(void);                                                   // Ends 2D mode with custom camera
void BeginMode3D(Camera3D camera);                                      // Initializes 3D mode with custom camera (3D)
void EndMode3D(void);                                                   // Ends 3D mode and returns to default 2D orthographic mode
void BeginTextureMode(RenderTexture2D target);                          // Initializes render texture for drawing
void EndTextureMode(void);                                              // Ends drawing to render texture
void BeginScissorMode(int x, int y, int width, int height);             // Begin scissor mode (define screen area for following drawing)
void EndScissorMode(void);                                              // End scissor mode
            
// Screen-space-related functions           
Ray GetMouseRay(Vector2 mousePosition, Camera camera);                  // Returns a ray trace from mouse position
Matrix GetCameraMatrix(Camera camera);                                  // Returns camera transform matrix (view matrix)
Matrix GetCameraMatrix2D(Camera2D camera);                              // Returns camera 2d transform matrix
Vector2 GetWorldToScreen(Vector3 position, Camera camera);              // Returns the screen space position for a 3d world space position
Vector2 GetWorldToScreenEx(Vector3 position, Camera camera,int width, int height); // Returns size position for a 3d world space position
Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera);          // Returns the screen space position for a 2d camera world space position
Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera);          // Returns the world space position for a 2d camera screen space position
            
// Timing-related functions         
void SetTargetFPS(int fps);                                             // Set target FPS (maximum)
int GetFPS(void);                                                       // Returns current FPS
float GetFrameTime(void);                                               // Returns time in seconds for last frame drawn
double GetTime(void);                                                   // Returns elapsed time in seconds since InitWindow()
            
// Color-related functions          
int ColorToInt(Color color);                                            // Returns hexadecimal value for a Color
Vector4 ColorNormalize(Color color);                                    // Returns color normalized as float [0..1]
Color ColorFromNormalized(Vector4 normalized);                          // Returns color from normalized values [0..1]
Vector3 ColorToHSV(Color color);                                        // Returns HSV values for a Color
Color ColorFromHSV(Vector3 hsv);                                        // Returns a Color from HSV values
Color GetColor(int hexValue);                                           // Returns a Color struct from hexadecimal value
Color Fade(Color color, float alpha);                                   // Color fade-in or fade-out, alpha goes from 0.0f to 1.0f
            
// Misc. functions          
void SetConfigFlags(unsigned int flags);                                // Setup window configuration flags (view FLAGS)
void TakeScreenshot(const char *fileName);                              // Takes a screenshot of current screen (saved a .png)
int GetRandomValue(int min, int max);                                   // Returns a random value between min and max (both included)
            
// Files management functions
unsigned char *LoadFileData(const char *fileName, int *bytesRead);      // Load file data as byte array (read)
void SaveFileData(const char *fileName, void *data, int bytesToWrite);  // Save data to file from byte array (write)
char *LoadFileText(const char *fileName);                               // Load text data from file (read), returns a '\0' terminated string
void SaveFileText(const char *fileName, char *text);                    // Save text data to file (write), string must be '\0' terminated    
bool FileExists(const char *fileName);                                  // Check if file exists
bool IsFileExtension(const char *fileName, const char *ext);            // Check file extension
bool DirectoryExists(const char *dirPath);                              // Check if a directory path exists
const char *GetExtension(const char *fileName);                         // Get pointer to extension for a filename string
const char *GetFileName(const char *filePath);                          // Get pointer to filename for a path string
const char *GetFileNameWithoutExt(const char *filePath);                // Get filename string without extension (uses static string)
const char *GetDirectoryPath(const char *filePath);                     // Get full path for a given fileName with path (uses static string)
const char *GetPrevDirectoryPath(const char *dirPath);                  // Get previous directory path for a given path (uses static string)
const char *GetWorkingDirectory(void);                                  // Get current working directory (uses static string)
char **GetDirectoryFiles(const char *dirPath, int *count);              // Get filenames in a directory path (memory should be freed)
void ClearDirectoryFiles(void);                                         // Clear directory files paths buffers (free memory)
bool ChangeDirectory(const char *dir);                                  // Change working directory, returns true if success
bool IsFileDropped(void);                                               // Check if a file has been dropped into window
char **GetDroppedFiles(int *count);                                     // Get dropped files names (memory should be freed)
void ClearDroppedFiles(void);                                           // Clear dropped files paths buffer (free memory)
long GetFileModTime(const char *fileName);                              // Get file modification time (last write time)

unsigned char *CompressData(unsigned char *data, int dataLength, int *compDataLength);        // Compress data (DEFLATE algorythm)
unsigned char *DecompressData(unsigned char *compData, int compDataLength, int *dataLength);  // Decompress data (DEFLATE algorythm)

// Persistent storage management
int LoadStorageValue(int position);                                     // Load integer value from storage file (from defined position)
void SaveStorageValue(int position, int value);                         // Save integer value to storage file (to defined position)

void OpenURL(const char *url);                                          // Open URL with default system browser (if available)

//------------------------------------------------------------------------------------
// Input Handling Functions
//------------------------------------------------------------------------------------

// Input-related functions: keyb
bool IsKeyPressed(int key);                                             // Detect if a key has been pressed once
bool IsKeyDown(int key);                                                // Detect if a key is being pressed
bool IsKeyReleased(int key);                                            // Detect if a key has been released once
bool IsKeyUp(int key);                                                  // Detect if a key is NOT being pressed
int GetKeyPressed(void);                                                // Get latest key pressed
void SetExitKey(int key);                                               // Set a custom key to exit program (default is ESC)
            
// Input-related functions: gamepads                
bool IsGamepadAvailable(int gamepad);                                   // Detect if a gamepad is available
bool IsGamepadName(int gamepad, const char *name);                      // Check gamepad name (if available)
const char *GetGamepadName(int gamepad);                                // Return gamepad internal name id
bool IsGamepadButtonPressed(int gamepad, int button);                   // Detect if a gamepad button has been pressed once
bool IsGamepadButtonDown(int gamepad, int button);                      // Detect if a gamepad button is being pressed
bool IsGamepadButtonReleased(int gamepad, int button);                  // Detect if a gamepad button has been released once
bool IsGamepadButtonUp(int gamepad, int button);                        // Detect if a gamepad button is NOT being pressed
int GetGamepadButtonPressed(void);                                      // Get the last gamepad button pressed
int GetGamepadAxisCount(int gamepad);                                   // Return gamepad axis count for a gamepad
float GetGamepadAxisMovement(int gamepad, int axis);                    // Return axis movement value for a gamepad axis
            
// Input-related functions: mouse               
bool IsMouseButtonPressed(int button);                                  // Detect if a mouse button has been pressed once
bool IsMouseButtonDown(int button);                                     // Detect if a mouse button is being pressed
bool IsMouseButtonReleased(int button);                                 // Detect if a mouse button has been released once
bool IsMouseButtonUp(int button);                                       // Detect if a mouse button is NOT being pressed
int GetMouseX(void);                                                    // Returns mouse position X
int GetMouseY(void);                                                    // Returns mouse position Y
Vector2 GetMousePosition(void);                                         // Returns mouse position XY
void SetMousePosition(int x, int y);                                    // Set mouse position XY
void SetMouseOffset(int offsetX, int offsetY);                          // Set mouse offset
void SetMouseScale(float scaleX, float scaleY);                         // Set mouse scaling
int GetMouseWheelMove(void);                                            // Returns mouse wheel movement Y

// Input-related functions: touch               
int GetTouchX(void);                                                    // Returns touch position X for touch point 0 (relative to screen size)
int GetTouchY(void);                                                    // Returns touch position Y for touch point 0 (relative to screen size)
Vector2 GetTouchPosition(int index);                                    // Returns touch position XY for a touch point index (relative to screen size)

//------------------------------------------------------------------------------------
// Gestures and Touch Handling Functions (Module: gestures)
//------------------------------------------------------------------------------------
void SetGesturesEnabled(unsigned int gestureFlags);                     // Enable a set of gestures using flags
bool IsGestureDetected(int gesture);                                    // Check if a gesture have been detected
int GetGestureDetected(void);                                           // Get latest detected gesture
int GetTouchPointsCount(void);                                          // Get touch points count
float GetGestureHoldDuration(void);                                     // Get gesture hold time in milliseconds
Vector2 GetGestureDragVector(void);                                     // Get gesture drag vector
float GetGestureDragAngle(void);                                        // Get gesture drag angle
Vector2 GetGesturePinchVector(void);                                    // Get gesture pinch delta
float GetGesturePinchAngle(void);                                       // Get gesture pinch angle

//------------------------------------------------------------------------------------
// Camera System Functions (Module: camera)
//------------------------------------------------------------------------------------
void SetCameraMode(Camera camera, int mode);                            // Set camera mode (multiple camera modes available)
void UpdateCamera(Camera *camera);                                      // Update camera position for selected mode
        
void SetCameraPanControl(int panKey);                                   // Set camera pan key to combine with mouse movement (free camera)
void SetCameraAltControl(int altKey);                                   // Set camera alt key to combine with mouse movement (free camera)
void SetCameraSmoothZoomControl(int szKey);                             // Set camera smooth zoom key to combine with mouse (free camera)
void SetCameraMoveControls(int frontKey, int backKey, 
                            int rightKey, int leftKey, 
                            int upKey, int downKey);                     // Set camera move controls (1st person and 3rd person cameras)
// Basic shapes drawing functions
void DrawPixel(int posX, int posY, Color color);                                                    // Draw a pixel
void DrawPixelV(Vector2 position, Color color);                                                     // Draw a pixel (Vector version)
void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);                 // Draw a line
void DrawLineV(Vector2 startPos, Vector2 endPos, Color color);                                      // Draw a line (Vector version)
void DrawLineEx(Vector2 startPos, Vector2 endPos, float thick, Color color);                        // Draw a line defining thickness
void DrawLineBezier(Vector2 startPos, Vector2 endPos, float thick, Color color);                    // Draw a line using cubic-bezier curves in-out
void DrawLineStrip(Vector2 *points, int numPoints, Color color);                                    // Draw lines sequence
void DrawCircle(int centerX, int centerY, float radius, Color color);                               // Draw a color-filled circle
void DrawCircleSector(Vector2 center, float radius, int startAngle, int endAngle, int segments, Color color);     // Draw a piece of a circle
void DrawCircleSectorLines(Vector2 center, float radius, int startAngle, int endAngle, int segments, Color color);    // Draw circle sector outline
void DrawCircleGradient(int centerX, int centerY, float radius, Color color1, Color color2);        // Draw a gradient-filled circle
void DrawCircleV(Vector2 center, float radius, Color color);                                        // Draw a color-filled circle (Vector version)
void DrawCircleLines(int centerX, int centerY, float radius, Color color);                          // Draw circle outline
void DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, Color color);              // Draw ellipse
void DrawEllipseLines(int centerX, int centerY, float radiusH, float radiusV, Color color);         // Draw ellipse outline
void DrawRing(Vector2 center, float innerRadius, float outerRadius, int startAngle, int endAngle, int segments, Color color); // Draw ring
void DrawRingLines(Vector2 center, float innerRadius, float outerRadius, int startAngle, int endAngle, int segments, Color color);    // Draw ring outline
void DrawRectangle(int posX, int posY, int width, int height, Color color);                         // Draw a color-filled rectangle
void DrawRectangleV(Vector2 position, Vector2 size, Color color);                                   // Draw a color-filled rectangle (Vector version)
void DrawRectangleRec(Rectangle rec, Color color);                                                  // Draw a color-filled rectangle
void DrawRectanglePro(Rectangle rec, Vector2 origin, float rotation, Color color);                  // Draw a color-filled rectangle with pro parameters
void DrawRectangleGradientV(int posX, int posY, int width, int height, Color color1, Color color2); // Draw a vertical-gradient-filled rectangle
void DrawRectangleGradientH(int posX, int posY, int width, int height, Color color1, Color color2); // Draw a horizontal-gradient-filled rectangle
void DrawRectangleGradientEx(Rectangle rec, Color col1, Color col2, Color col3, Color col4);        // Draw a gradient-filled rectangle with custom vertex colors
void DrawRectangleLines(int posX, int posY, int width, int height, Color color);                    // Draw rectangle outline
void DrawRectangleLinesEx(Rectangle rec, int lineThick, Color color);                               // Draw rectangle outline with extended parameters
void DrawRectangleRounded(Rectangle rec, float roundness, int segments, Color color);               // Draw rectangle with rounded edges
void DrawRectangleRoundedLines(Rectangle rec, float roundness, int segments, int lineThick, Color color); // Draw rectangle with rounded edges outline
void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3, Color color);                                 // Draw a color-filled triangle (vertex in counter-clockwise order!)
void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color);                            // Draw triangle outline (vertex in counter-clockwise order!)
void DrawTriangleFan(Vector2 *points, int numPoints, Color color);                                  // Draw a triangle fan defined by points (first vertex is the center)
void DrawTriangleStrip(Vector2 *points, int pointsCount, Color color);                              // Draw a triangle strip defined by points
void DrawPoly(Vector2 center, int sides, float radius, float rotation, Color color);                // Draw a regular polygon (Vector version)
void DrawPolyLines(Vector2 center, int sides, float radius, float rotation, Color color);           // Draw a polygon outline of n sides

// Basic shapes collision detection functions
bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2);                                            // Check collision between two rectangles
bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2);         // Check collision between two circles
bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec);                          // Check collision between circle and rectangle
Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2);                                          // Get collision rectangle for two rectangles collision
bool CheckCollisionPointRec(Vector2 point, Rectangle rec);                                          // Check if point is inside rectangle
bool CheckCollisionPointCircle(Vector2 point, Vector2 center, float radius);                        // Check if point is inside circle
bool CheckCollisionPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3);                // Check if point is inside a triangle

// Image loading functions
// NOTE: This functions do not require GPU access
Image LoadImage(const char *fileName);                                                             // Load image from file into CPU memory (RAM)
Image LoadImageEx(Color *pixels, int width, int height);                                           // Load image from Color array data (RGBA - 32bit)
Image LoadImagePro(void *data, int width, int height, int format);                                 // Load image from raw data with parameters
Image LoadImageRaw(const char *fileName, int width, int height, int format, int headerSize);       // Load image from RAW file data
void UnloadImage(Image image);                                                                     // Unload image from CPU memory (RAM)
void ExportImage(Image image, const char *fileName);                                               // Export image data to file
void ExportImageAsCode(Image image, const char *fileName);                                         // Export image as code file defining an array of bytes
Color *GetImageData(Image image);                                                                  // Get pixel data from image as a Color struct array
Vector4 *GetImageDataNormalized(Image image);                                                      // Get pixel data from image as Vector4 array (float normalized)

// Image generation functions
Image GenImageColor(int width, int height, Color color);                                           // Generate image: plain color
Image GenImageGradientV(int width, int height, Color top, Color bottom);                           // Generate image: vertical gradient
Image GenImageGradientH(int width, int height, Color left, Color right);                           // Generate image: horizontal gradient
Image GenImageGradientRadial(int width, int height, float density, Color inner, Color outer);      // Generate image: radial gradient
Image GenImageChecked(int width, int height, int checksX, int checksY, Color col1, Color col2);    // Generate image: checked
Image GenImageWhiteNoise(int width, int height, float factor);                                     // Generate image: white noise
Image GenImagePerlinNoise(int width, int height, int offsetX, int offsetY, float scale);           // Generate image: perlin noise
Image GenImageCellular(int width, int height, int tileSize);                                       // Generate image: cellular algorithm. Bigger tileSize means bigger cells

// Image manipulation functions
Image ImageCopy(Image image);                                                                      // Create an image duplicate (useful for transformations)
Image ImageFromImage(Image image, Rectangle rec);                                                  // Create an image from another image piece
Image ImageText(const char *text, int fontSize, Color color);                                      // Create an image from text (default font)
Image ImageTextEx(Font font, const char *text, float fontSize, float spacing, Color tint);         // Create an image from text (custom sprite font)
void ImageToPOT(Image *image, Color fillColor);                                                    // Convert image to POT (power-of-two)
void ImageFormat(Image *image, int newFormat);                                                     // Convert image data to desired format
void ImageAlphaMask(Image *image, Image alphaMask);                                                // Apply alpha mask to image
void ImageAlphaClear(Image *image, Color color, float threshold);                                  // Clear alpha channel to desired color
void ImageAlphaCrop(Image *image, float threshold);                                                // Crop image depending on alpha value
void ImageAlphaPremultiply(Image *image);                                                          // Premultiply alpha channel
void ImageCrop(Image *image, Rectangle crop);                                                      // Crop an image to a defined rectangle
void ImageResize(Image *image, int newWidth, int newHeight);                                       // Resize image (Bicubic scaling algorithm)
void ImageResizeNN(Image *image, int newWidth,int newHeight);                                      // Resize image (Nearest-Neighbor scaling algorithm)
void ImageResizeCanvas(Image *image, int newWidth, int newHeight, int offsetX, int offsetY, Color color);  // Resize canvas and fill with color
void ImageMipmaps(Image *image);                                                                   // Generate all mipmap levels for a provided image
void ImageDither(Image *image, int rBpp, int gBpp, int bBpp, int aBpp);                            // Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
void ImageFlipVertical(Image *image);                                                              // Flip image vertically
void ImageFlipHorizontal(Image *image);                                                            // Flip image horizontally
void ImageRotateCW(Image *image);                                                                  // Rotate image clockwise 90deg
void ImageRotateCCW(Image *image);                                                                 // Rotate image counter-clockwise 90deg
void ImageColorTint(Image *image, Color color);                                                    // Modify image color: tint
void ImageColorInvert(Image *image);                                                               // Modify image color: invert
void ImageColorGrayscale(Image *image);                                                            // Modify image color: grayscale
void ImageColorContrast(Image *image, float contrast);                                             // Modify image color: contrast (-100 to 100)
void ImageColorBrightness(Image *image, int brightness);                                           // Modify image color: brightness (-255 to 255)
void ImageColorReplace(Image *image, Color color, Color replace);                                  // Modify image color: replace color
Color *ImageExtractPalette(Image image, int maxPaletteSize, int *extractCount);                    // Extract color palette from image to maximum size (memory should be freed)
Rectangle GetImageAlphaBorder(Image image, float threshold);                                       // Get image alpha border rectangle

// Image drawing functions
// NOTE: Image software-rendering functions (CPU)
void ImageClearBackground(Image *dst, Color color);                                                // Clear image background with given color
void ImageDrawPixel(Image *dst, int posX, int posY, Color color);                                  // Draw pixel within an image
void ImageDrawPixelV(Image *dst, Vector2 position, Color color);                                   // Draw pixel within an image (Vector version)
void ImageDrawLine(Image *dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color); // Draw line within an image
void ImageDrawLineV(Image *dst, Vector2 start, Vector2 end, Color color);                          // Draw line within an image (Vector version)
void ImageDrawCircle(Image *dst, int centerX, int centerY, int radius, Color color);               // Draw circle within an image
void ImageDrawCircleV(Image *dst, Vector2 center, int radius, Color color);                        // Draw circle within an image (Vector version)
void ImageDrawRectangle(Image *dst, int posX, int posY, int width, int height, Color color);       // Draw rectangle within an image
void ImageDrawRectangleV(Image *dst, Vector2 position, Vector2 size, Color color);                 // Draw rectangle within an image (Vector version)
void ImageDrawRectangleRec(Image *dst, Rectangle rec, Color color);                                // Draw rectangle within an image 
void ImageDrawRectangleLines(Image *dst, Rectangle rec, int thick, Color color);                   // Draw rectangle lines within an image
void ImageDraw(Image *dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint);             // Draw a source image within a destination image (tint applied to source)
void ImageDrawText(Image *dst, Vector2 position, const char *text, int fontSize, Color color);     // Draw text (default font) within an image (destination)
void ImageDrawTextEx(Image *dst, Vector2 position, Font font, const char *text, float fontSize, float spacing, Color color); // Draw text (custom sprite font) within an image (destination)

// Texture loading functions
// NOTE: These functions require GPU access
Texture2D LoadTexture(const char *fileName);                                                       // Load texture from file into GPU memory (VRAM)
Texture2D LoadTextureFromImage(Image image);                                                       // Load texture from image data
TextureCubemap LoadTextureCubemap(Image image, int layoutType);                                    // Load cubemap from image, multiple image cubemap layouts supported
RenderTexture2D LoadRenderTexture(int width, int height);                                          // Load texture for rendering (framebuffer)
void UnloadTexture(Texture2D texture);                                                             // Unload texture from GPU memory (VRAM)
void UnloadRenderTexture(RenderTexture2D target);                                                  // Unload render texture from GPU memory (VRAM)
void UpdateTexture(Texture2D texture, const void *pixels);                                         // Update GPU texture with new data
Image GetTextureData(Texture2D texture);                                                           // Get pixel data from GPU texture and return an Image
Image GetScreenData(void);                                                                         // Get pixel data from screen buffer and return an Image (screenshot)

// Texture configuration functions
void GenTextureMipmaps(Texture2D *texture);                                                        // Generate GPU mipmaps for a texture
void SetTextureFilter(Texture2D texture, int filterMode);                                          // Set texture scaling filter mode
void SetTextureWrap(Texture2D texture, int wrapMode);                                              // Set texture wrapping mode

// Texture drawing functions
void DrawTexture(Texture2D texture, int posX, int posY, Color tint);                               // Draw a Texture2D
void DrawTextureV(Texture2D texture, Vector2 position, Color tint);                                // Draw a Texture2D with position defined as Vector2
void DrawTextureEx(Texture2D texture, Vector2 position, float rotation, float scale, Color tint);  // Draw a Texture2D with extended parameters
void DrawTextureRec(Texture2D texture, Rectangle sourceRec, Vector2 position, Color tint);         // Draw a part of a texture defined by a rectangle
void DrawTextureQuad(Texture2D texture, Vector2 tiling, Vector2 offset, Rectangle quad, Color tint);  // Draw texture quad with tiling and offset parameters
void DrawTexturePro(Texture2D texture, Rectangle sourceRec, Rectangle destRec, Vector2 origin, float rotation, Color tint);       // Draw a part of a texture defined by a rectangle with 'pro' parameters
void DrawTextureNPatch(Texture2D texture, NPatchInfo nPatchInfo, Rectangle destRec, Vector2 origin, float rotation, Color tint);  // Draws a texture (or part of it) that stretches or shrinks nicely

// Image/Texture misc functions
int GetPixelDataSize(int width, int height, int format);                                           // Get pixel data size in bytes (image or texture)

// Font loading/unloading functions
Font GetFontDefault(void);                                                                        // Get the default Font
Font LoadFont(const char *fileName);                                                              // Load font from file into GPU memory (VRAM)
Font LoadFontEx(const char *fileName, int fontSize, int *fontChars, int charsCount);              // Load font from file with extended parameters
Font LoadFontFromImage(Image image, Color key, int firstChar);                                    // Load font from Image (XNA style)
CharInfo *LoadFontData(const char *fileName, int fontSize, int *fontChars, int charsCount, int type); // Load font data for further use
Image GenImageFontAtlas(const CharInfo *chars, Rectangle **recs, int charsCount, int fontSize, int padding, int packMethod);  // Generate image font atlas using chars info
void UnloadFont(Font font);                                                                       // Unload Font from GPU memory (VRAM)

// Text drawing functions
void DrawFPS(int posX, int posY);                                                                 // Shows current FPS
void DrawText(const char *text, int posX, int posY, int fontSize, Color color);                   // Draw text (using default font)
void DrawTextEx(Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint);                // Draw text using font and additional parameters
void DrawTextRec(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint);   // Draw text using font inside rectangle limits
void DrawTextRecEx(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint,
                int selectStart, int selectLength, Color selectTint, Color selectBackTint);       // Draw text using font inside rectangle limits with support for text selection
void DrawTextCodepoint(Font font, int codepoint, Vector2 position, float scale, Color tint);      // Draw one character (codepoint)

// Text misc. functions
int MeasureText(const char *text, int fontSize);                                                  // Measure string width for default font
Vector2 MeasureTextEx(Font font, const char *text, float fontSize, float spacing);                // Measure string size for Font
int GetGlyphIndex(Font font, int codepoint);                                                      // Get index position for a unicode character on font

// Text strings management functions (no utf8 strings, only byte chars)
// NOTE: Some strings allocate memory internally for returned strings, just be careful!
int TextCopy(char *dst, const char *src);                                                         // Copy one string to another, returns bytes copied
bool TextIsEqual(const char *text1, const char *text2);                                           // Check if two text string are equal
unsigned int TextLength(const char *text);                                                        // Get text length, checks for '\0' ending
const char *TextFormat(const char *text, ...);                                                    // Text formatting with variables (sprintf style)
const char *TextSubtext(const char *text, int position, int length);                              // Get a piece of a text string
char *TextReplace(char *text, const char *replace, const char *by);                               // Replace text string (memory must be freed!)
char *TextInsert(const char *text, const char *insert, int position);                             // Insert text in a position (memory must be freed!)
const char *TextJoin(const char **textList, int count, const char *delimiter);                    // Join text strings with delimiter
const char **TextSplit(const char *text, char delimiter, int *count);                             // Split text into multiple strings
void TextAppend(char *text, const char *append, int *position);                                   // Append text at specific position and move cursor!
int TextFindIndex(const char *text, const char *find);                                            // Find first text occurrence within a string
const char *TextToUpper(const char *text);                                                        // Get upper case version of provided string
const char *TextToLower(const char *text);                                                        // Get lower case version of provided string
const char *TextToPascal(const char *text);                                                       // Get Pascal case notation version of provided string
int TextToInteger(const char *text);                                                              // Get integer value from text (negative values not supported)
char *TextToUtf8(int *codepoints, int length);                                                    // Encode text codepoint into utf8 text (memory must be freed!)
                                                                                                    
// UTF8 text strings management functions                                                         
int *GetCodepoints(const char *text, int *count);                                                 // Get all codepoints in a string, codepoints count returned by parameters
int GetCodepointsCount(const char *text);                                                         // Get total number of characters (codepoints) in a UTF8 encoded string
int GetNextCodepoint(const char *text, int *bytesProcessed);                                      // Returns next codepoint in a UTF8 encoded string; 0x3f('?') is returned on failure
const char *CodepointToUtf8(int codepoint, int *byteLength);                                      // Encode codepoint into utf8 text (char array length returned as parameter)

    // Basic geometric 3D shapes drawing functions
void DrawLine3D(Vector3 startPos, Vector3 endPos, Color color);                                    // Draw a line in 3D world space
void DrawPoint3D(Vector3 position, Color color);                                                   // Draw a point in 3D space, actually a small line
void DrawCircle3D(Vector3 center, float radius, Vector3 rotationAxis, float rotationAngle, Color color); // Draw a circle in 3D world space
void DrawCube(Vector3 position, float width, float height, float length, Color color);             // Draw cube
void DrawCubeV(Vector3 position, Vector3 size, Color color);                                       // Draw cube (Vector version)
void DrawCubeWires(Vector3 position, float width, float height, float length, Color color);        // Draw cube wires
void DrawCubeWiresV(Vector3 position, Vector3 size, Color color);                                  // Draw cube wires (Vector version)
void DrawCubeTexture(Texture2D texture, Vector3 position, float width, float height, float length, Color color); // Draw cube textured
void DrawSphere(Vector3 centerPos, float radius, Color color);                                     // Draw sphere
void DrawSphereEx(Vector3 centerPos, float radius, int rings, int slices, Color color);            // Draw sphere with extended parameters
void DrawSphereWires(Vector3 centerPos, float radius, int rings, int slices, Color color);         // Draw sphere wires
void DrawCylinder(Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color); // Draw a cylinder/cone
void DrawCylinderWires(Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color); // Draw a cylinder/cone wires
void DrawPlane(Vector3 centerPos, Vector2 size, Color color);                                      // Draw a plane XZ
void DrawRay(Ray ray, Color color);                                                                // Draw a ray line
void DrawGrid(int slices, float spacing);                                                          // Draw a grid (centered at (0, 0, 0))
void DrawGizmo(Vector3 position);                                                                  // Draw simple gizmo

// Model loading/unloading functions
Model LoadModel(const char *fileName);                                                             // Load model from files (meshes and materials)
Model LoadModelFromMesh(Mesh mesh);                                                                // Load model from generated mesh (default material)
void UnloadModel(Model model);                                                                     // Unload model from memory (RAM and/or VRAM)

// Mesh loading/unloading functions
Mesh *LoadMeshes(const char *fileName, int *meshCount);                                            // Load meshes from model file
void ExportMesh(Mesh mesh, const char *fileName);                                                  // Export mesh data to file
void UnloadMesh(Mesh mesh);                                                                        // Unload mesh from memory (RAM and/or VRAM)

// Material loading/unloading functions
Material *LoadMaterials(const char *fileName, int *materialCount);                                 // Load materials from model file
Material LoadMaterialDefault(void);                                                                // Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
void UnloadMaterial(Material material);                                                            // Unload material from GPU memory (VRAM)
void SetMaterialTexture(Material *material, int mapType, Texture2D texture);                       // Set texture for a material map type (MAP_DIFFUSE, MAP_SPECULAR...)
void SetModelMeshMaterial(Model *model, int meshId, int materialId);                               // Set material for a mesh

// Model animations loading/unloading functions
ModelAnimation *LoadModelAnimations(const char *fileName, int *animsCount);                        // Load model animations from file
void UpdateModelAnimation(Model model, ModelAnimation anim, int frame);                            // Update model animation pose
void UnloadModelAnimation(ModelAnimation anim);                                                    // Unload animation data
bool IsModelAnimationValid(Model model, ModelAnimation anim);                                      // Check model animation skeleton match

// Mesh generation functions
Mesh GenMeshPoly(int sides, float radius);                                                         // Generate polygonal mesh
Mesh GenMeshPlane(float width, float length, int resX, int resZ);                                  // Generate plane mesh (with subdivisions)
Mesh GenMeshCube(float width, float height, float length);                                         // Generate cuboid mesh
Mesh GenMeshSphere(float radius, int rings, int slices);                                           // Generate sphere mesh (standard sphere)
Mesh GenMeshHemiSphere(float radius, int rings, int slices);                                       // Generate half-sphere mesh (no bottom cap)
Mesh GenMeshCylinder(float radius, float height, int slices);                                      // Generate cylinder mesh
Mesh GenMeshTorus(float radius, float size, int radSeg, int sides);                                // Generate torus mesh
Mesh GenMeshKnot(float radius, float size, int radSeg, int sides);                                 // Generate trefoil knot mesh
Mesh GenMeshHeightmap(Image heightmap, Vector3 size);                                              // Generate heightmap mesh from image data
Mesh GenMeshCubicmap(Image cubicmap, Vector3 cubeSize);                                            // Generate cubes-based map mesh from image data

// Mesh manipulation functions
BoundingBox MeshBoundingBox(Mesh mesh);                                                            // Compute mesh bounding box limits
void MeshTangents(Mesh *mesh);                                                                     // Compute mesh tangents
void MeshBinormals(Mesh *mesh);                                                                    // Compute mesh binormals

// Model drawing functions
void DrawModel(Model model, Vector3 position, float scale, Color tint);                            // Draw a model (with texture if set)
void DrawModelEx(Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint); // Draw a model with extended parameters
void DrawModelWires(Model model, Vector3 position, float scale, Color tint);                       // Draw a model wires (with texture if set)
void DrawModelWiresEx(Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint); // Draw a model wires (with texture if set) with extended parameters
void DrawBoundingBox(BoundingBox box, Color color);                                                // Draw bounding box (wires)
void DrawBillboard(Camera camera, Texture2D texture, Vector3 center, float size, Color tint);      // Draw a billboard texture
void DrawBillboardRec(Camera camera, Texture2D texture, Rectangle sourceRec, Vector3 center, float size, Color tint); // Draw a billboard texture defined by sourceRec

// Collision detection functions
bool CheckCollisionSpheres(Vector3 centerA, float radiusA, Vector3 centerB, float radiusB);        // Detect collision between two spheres
bool CheckCollisionBoxes(BoundingBox box1, BoundingBox box2);                                      // Detect collision between two bounding boxes
bool CheckCollisionBoxSphere(BoundingBox box, Vector3 center, float radius);                       // Detect collision between box and sphere
bool CheckCollisionRaySphere(Ray ray, Vector3 center, float radius);                               // Detect collision between ray and sphere
bool CheckCollisionRaySphereEx(Ray ray, Vector3 center, float radius, Vector3 *collisionPoint);    // Detect collision between ray and sphere, returns collision point
bool CheckCollisionRayBox(Ray ray, BoundingBox box);                                               // Detect collision between ray and box
RayHitInfo GetCollisionRayModel(Ray ray, Model model);                                             // Get collision info between ray and model
RayHitInfo GetCollisionRayTriangle(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3);                   // Get collision info between ray and triangle
RayHitInfo GetCollisionRayGround(Ray ray, float groundHeight);                                     // Get collision info between ray and ground plane (Y-normal plane)

// Shader loading/unloading functions
char *LoadText(const char *fileName);                                                               // Load chars array from text file
Shader LoadShader(const char *vsFileName, const char *fsFileName);                                  // Load shader from files and bind default locations
Shader LoadShaderCode(char *vsCode, char *fsCode);                                                  // Load shader from code strings and bind default locations
void UnloadShader(Shader shader);                                                                   // Unload shader from GPU memory (VRAM)
                            
Shader GetShaderDefault(void);                                                                      // Get default shader
Texture2D GetTextureDefault(void);                                                                  // Get default texture
Texture2D GetShapesTexture(void);                                                                   // Get texture to draw shapes
Rectangle GetShapesTextureRec(void);                                                                // Get texture rectangle to draw shapes
void SetShapesTexture(Texture2D texture, Rectangle source);                                         // Define default texture used to draw shapes

// Shader configuration functions                               
int GetShaderLocation(Shader shader, const char *uniformName);                                      // Get shader uniform location
void SetShaderValue(Shader shader, int uniformLoc, const void *value, int uniformType);             // Set shader uniform value
void SetShaderValueV(Shader shader, int uniformLoc, const void *value, int uniformType, int count); // Set shader uniform value vector
void SetShaderValueMatrix(Shader shader, int uniformLoc, Matrix mat);                               // Set shader uniform value (matrix 4x4)
void SetShaderValueTexture(Shader shader, int uniformLoc, Texture2D texture);                       // Set shader uniform value for texture
void SetMatrixProjection(Matrix proj);                                                              // Set a custom projection matrix (replaces internal projection matrix)
void SetMatrixModelview(Matrix view);                                                               // Set a custom modelview matrix (replaces internal modelview matrix)
Matrix GetMatrixModelview();                                                                        // Get internal modelview matrix
Matrix GetMatrixProjection(void);                                                                   // Get internal projection matrix

// Shading begin/end functions
void BeginShaderMode(Shader shader);                                                                // Begin custom shader drawing
void EndShaderMode(void);                                                                           // End custom shader drawing (use default shader)
void BeginBlendMode(int mode);                                                                      // Begin blending mode (alpha, additive, multiplied)
void EndBlendMode(void);                                                                            // End blending mode (reset to default: alpha blending)

// VR control functions
void InitVrSimulator(void);                                                                         // Init VR simulator for selected device parameters
void CloseVrSimulator(void);                                                                        // Close VR simulator for current device
void UpdateVrTracking(Camera *camera);                                                              // Update VR tracking (position and orientation) and camera
void SetVrConfiguration(VrDeviceInfo info, Shader distortion);                                      // Set stereo rendering configuration parameters 
bool IsVrSimulatorReady(void);                                                                      // Detect if VR simulator is ready
void ToggleVrMode(void);                                                                            // Enable/Disable VR experience
void BeginVrDrawing(void);                                                                          // Begin VR simulator stereo rendering
void EndVrDrawing(void);                                                                            // End VR simulator stereo rendering

// Audio device management functions
void InitAudioDevice(void);                                                     // Initialize audio device and context
void CloseAudioDevice(void);                                                    // Close the audio device and context (and music stream)
bool IsAudioDeviceReady(void);                                                  // Check if audio device is ready
void SetMasterVolume(float volume);                                             // Set master volume (listener)

// Wave/Sound loading/unloading functions
Wave LoadWave(const char *fileName);                                            // Load wave data from file
Wave LoadWaveEx(void *data, int sampleCount, int sampleRate, int sampleSize, int channels); // Load wave data from raw array data
Sound LoadSound(const char *fileName);                                          // Load sound from file
Sound LoadSoundFromWave(Wave wave);                                             // Load sound from wave data
void UpdateSound(Sound sound, const void *data, int samplesCount);              // Update sound buffer with new data
void UnloadWave(Wave wave);                                                     // Unload wave data
void UnloadSound(Sound sound);                                                  // Unload sound
void ExportWave(Wave wave, const char *fileName);                               // Export wave data to file
void ExportWaveAsCode(Wave wave, const char *fileName);                         // Export wave sample data to code (.h)

// Wave/Sound management functions
void PlaySound(Sound sound);                                                    // Play a sound
void StopSound(Sound sound);                                                    // Stop playing a sound
void PauseSound(Sound sound);                                                   // Pause a sound
void ResumeSound(Sound sound);                                                  // Resume a paused sound
void PlaySoundMulti(Sound sound);                                               // Play a sound (using multichannel buffer pool)
void StopSoundMulti(void);                                                      // Stop any sound playing (using multichannel buffer pool)
int GetSoundsPlaying(void);                                                     // Get number of sounds playing in the multichannel
bool IsSoundPlaying(Sound sound);                                               // Check if a sound is currently playing
void SetSoundVolume(Sound sound, float volume);                                 // Set volume for a sound (1.0 is max level)
void SetSoundPitch(Sound sound, float pitch);                                   // Set pitch for a sound (1.0 is base level)
void WaveFormat(Wave *wave, int sampleRate, int sampleSize, int channels);      // Convert wave data to desired format
Wave WaveCopy(Wave wave);                                                       // Copy a wave to a new wave
void WaveCrop(Wave *wave, int initSample, int finalSample);                     // Crop a wave to defined samples range
float *GetWaveData(Wave wave);                                                  // Get samples data from wave as a floats array

// Music management functions
Music LoadMusicStream(const char *fileName);                                    // Load music stream from file
void UnloadMusicStream(Music music);                                            // Unload music stream
void PlayMusicStream(Music music);                                              // Start music playing
void UpdateMusicStream(Music music);                                            // Updates buffers for music streaming
void StopMusicStream(Music music);                                              // Stop music playing
void PauseMusicStream(Music music);                                             // Pause music playing
void ResumeMusicStream(Music music);                                            // Resume playing paused music
bool IsMusicPlaying(Music music);                                               // Check if music is playing
void SetMusicVolume(Music music, float volume);                                 // Set volume for music (1.0 is max level)
void SetMusicPitch(Music music, float pitch);                                   // Set pitch for a music (1.0 is base level)
void SetMusicLoopCount(Music music, int count);                                 // Set music loop count (loop repeats)
float GetMusicTimeLength(Music music);                                          // Get music time length (in seconds)
float GetMusicTimePlayed(Music music);                                          // Get current music time played (in seconds)

// AudioStream management functions
AudioStream InitAudioStream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels); // Init audio stream (to stream raw audio pcm data)
void UpdateAudioStream(AudioStream stream, const void *data, int samplesCount); // Update audio stream buffers with data
void CloseAudioStream(AudioStream stream);                                      // Close audio stream and free memory
bool IsAudioBufferProcessed(AudioStream stream);                                // Check if any audio stream buffers requires refill
void PlayAudioStream(AudioStream stream);                                       // Play audio stream
void PauseAudioStream(AudioStream stream);                                      // Pause audio stream
void ResumeAudioStream(AudioStream stream);                                     // Resume audio stream
bool IsAudioStreamPlaying(AudioStream stream);                                  // Check if audio stream is playing
void StopAudioStream(AudioStream stream);                                       // Stop audio stream
void SetAudioStreamVolume(AudioStream stream, float volume);                    // Set volume for audio stream (1.0 is max level)
void SetAudioStreamPitch(AudioStream stream, float pitch);                      // Set pitch for audio stream (1.0 is base level)
]]

mt = {__index = lib}
rl = setmetatable({}, mt)

-- raylib Config Flags
rl.PI = 3.14159265358979323846
rl.FLAG_SHOW_LOGO           =  1       -- Set to show raylib logo at startup
rl.FLAG_FULLSCREEN_MODE     =  2       -- Set to run program in fullscreen
rl.FLAG_WINDOW_RESIZABLE    =  4       -- Set to allow resizable window
rl.FLAG_WINDOW_UNDECORATED  =  8       -- Set to disable window decoration (frame and buttons)
rl.FLAG_WINDOW_TRANSPARENT  = 16       -- Set to allow transparent window
rl.FLAG_MSAA_4X_HINT        = 32       -- Set to try enabling MSAA 4X
rl.FLAG_VSYNC_HINT          = 64       -- Set to try enabling V-Sync on GPU

-- Keyboard Function Keys
rl.KEY_SPACE         =  32
rl.KEY_ESCAPE        = 256
rl.KEY_ENTER         = 257
rl.KEY_TAB           = 258
rl.KEY_BACKSPACE     = 259
rl.KEY_INSERT        = 260
rl.KEY_DELETE        = 261
rl.KEY_RIGHT         = 262
rl.KEY_LEFT          = 263
rl.KEY_DOWN          = 264
rl.KEY_UP            = 265
rl.KEY_PAGE_UP       = 266
rl.KEY_PAGE_DOWN     = 267
rl.KEY_HOME          = 268
rl.KEY_END           = 269
rl.KEY_CAPS_LOCK     = 280
rl.KEY_SCROLL_LOCK   = 281
rl.KEY_NUM_LOCK      = 282
rl.KEY_PRINT_SCREEN  = 283
rl.KEY_PAUSE         = 284
rl.KEY_F1            = 290
rl.KEY_F2            = 291
rl.KEY_F3            = 292
rl.KEY_F4            = 293
rl.KEY_F5            = 294
rl.KEY_F6            = 295
rl.KEY_F7            = 296
rl.KEY_F8            = 297
rl.KEY_F9            = 298
rl.KEY_F10           = 299
rl.KEY_F11           = 300
rl.KEY_F12           = 301
rl.KEY_LEFT_SHIFT    = 340
rl.KEY_LEFT_CONTROL  = 341
rl.KEY_LEFT_ALT      = 342
rl.KEY_RIGHT_SHIFT   = 344
rl.KEY_RIGHT_CONTROL = 345
rl.KEY_RIGHT_ALT     = 346
rl.KEY_GRAVE         =  96
rl.KEY_SLASH         =  47
rl.KEY_BACKSLASH     =  92

-- Keyboard Alpha Numeric Keys
rl.KEY_ZERO          =  48
rl.KEY_ONE           =  49
rl.KEY_TWO           =  50
rl.KEY_THREE         =  51
rl.KEY_FOUR          =  52
rl.KEY_FIVE          =  53
rl.KEY_SIX           =  54
rl.KEY_SEVEN         =  55
rl.KEY_EIGHT         =  56
rl.KEY_NINE          =  57
rl.KEY_A             =  65
rl.KEY_B             =  66
rl.KEY_C             =  67
rl.KEY_D             =  68
rl.KEY_E             =  69
rl.KEY_F             =  70
rl.KEY_G             =  71
rl.KEY_H             =  72
rl.KEY_I             =  73
rl.KEY_J             =  74
rl.KEY_K             =  75
rl.KEY_L             =  76
rl.KEY_M             =  77
rl.KEY_N             =  78
rl.KEY_O             =  79
rl.KEY_P             =  80
rl.KEY_Q             =  81
rl.KEY_R             =  82
rl.KEY_S             =  83
rl.KEY_T             =  84
rl.KEY_U             =  85
rl.KEY_V             =  86
rl.KEY_W             =  87
rl.KEY_X             =  88
rl.KEY_Y             =  89
rl.KEY_Z             =  90

-- Android Physical Buttons
rl.KEY_BACK          =   4
rl.KEY_MENU          =  82
rl.KEY_VOLUME_UP     =  24
rl.KEY_VOLUME_DOWN   =  25

-- Mouse Buttons
rl.MOUSE_LEFT_BUTTON   = 0
rl.MOUSE_RIGHT_BUTTON  = 1
rl.MOUSE_MIDDLE_BUTTON = 2

-- Touch points registered
rl.MAX_TOUCH_POINTS    = 2

-- Gamepad Number
rl.GAMEPAD_PLAYER1     = 0
rl.GAMEPAD_PLAYER2     = 1
rl.GAMEPAD_PLAYER3     = 2
rl.GAMEPAD_PLAYER4     = 3

-- Gamepad Buttons/Axis

-- PS3 USB Controller Buttons
rl.GAMEPAD_PS3_BUTTON_TRIANGLE =  0
rl.GAMEPAD_PS3_BUTTON_CIRCLE   =  1
rl.GAMEPAD_PS3_BUTTON_CROSS    =  2
rl.GAMEPAD_PS3_BUTTON_SQUARE   =  3
rl.GAMEPAD_PS3_BUTTON_L1       =  6
rl.GAMEPAD_PS3_BUTTON_R1       =  7
rl.GAMEPAD_PS3_BUTTON_L2       =  4
rl.GAMEPAD_PS3_BUTTON_R2       =  5
rl.GAMEPAD_PS3_BUTTON_START    =  8
rl.GAMEPAD_PS3_BUTTON_SELECT   =  9
rl.GAMEPAD_PS3_BUTTON_UP       = 24
rl.GAMEPAD_PS3_BUTTON_RIGHT    = 25
rl.GAMEPAD_PS3_BUTTON_DOWN     = 26
rl.GAMEPAD_PS3_BUTTON_LEFT     = 27
rl.GAMEPAD_PS3_BUTTON_PS       = 12

-- PS3 USB Controller Axis
rl.GAMEPAD_PS3_AXIS_LEFT_X   = 0
rl.GAMEPAD_PS3_AXIS_LEFT_Y   = 1
rl.GAMEPAD_PS3_AXIS_RIGHT_X  = 2
rl.GAMEPAD_PS3_AXIS_RIGHT_Y  = 5
rl.GAMEPAD_PS3_AXIS_L2       = 3       -- [1..-1] (pressure-level)
rl.GAMEPAD_PS3_AXIS_R2       = 4       -- [1..-1] (pressure-level)

-- Xbox360 USB Controller Buttons
rl.GAMEPAD_XBOX_BUTTON_A      = 0
rl.GAMEPAD_XBOX_BUTTON_B      = 1
rl.GAMEPAD_XBOX_BUTTON_X      = 2
rl.GAMEPAD_XBOX_BUTTON_Y      = 3
rl.GAMEPAD_XBOX_BUTTON_LB     = 4
rl.GAMEPAD_XBOX_BUTTON_RB     = 5
rl.GAMEPAD_XBOX_BUTTON_SELECT = 6
rl.GAMEPAD_XBOX_BUTTON_START  = 7
rl.GAMEPAD_XBOX_BUTTON_UP     = 10
rl.GAMEPAD_XBOX_BUTTON_RIGHT  = 11
rl.GAMEPAD_XBOX_BUTTON_DOWN   = 12
rl.GAMEPAD_XBOX_BUTTON_LEFT   = 13
rl.GAMEPAD_XBOX_BUTTON_HOME   = 8

-- Android Gamepad Controller (SNES CLASSIC)
rl.GAMEPAD_ANDROID_DPAD_UP      = 19
rl.GAMEPAD_ANDROID_DPAD_DOWN    = 20
rl.GAMEPAD_ANDROID_DPAD_LEFT    = 21
rl.GAMEPAD_ANDROID_DPAD_RIGHT   = 22
rl.GAMEPAD_ANDROID_DPAD_CENTER  = 23

rl.GAMEPAD_ANDROID_BUTTON_A     = 96
rl.GAMEPAD_ANDROID_BUTTON_B     = 97
rl.GAMEPAD_ANDROID_BUTTON_C     = 98
rl.GAMEPAD_ANDROID_BUTTON_X     = 99
rl.GAMEPAD_ANDROID_BUTTON_Y     = 100
rl.GAMEPAD_ANDROID_BUTTON_Z     = 101
rl.GAMEPAD_ANDROID_BUTTON_L1    = 102
rl.GAMEPAD_ANDROID_BUTTON_R1    = 103
rl.GAMEPAD_ANDROID_BUTTON_L2    = 104
rl.GAMEPAD_ANDROID_BUTTON_R2    = 105

-- Xbox360 USB Controller Axis
-- NOTE: For Raspberry Pi, axis must be reconfigured
--#if defined(PLATFORM_RPI)
rl.GAMEPAD_XBOX_AXIS_LEFT_X  = 0   -- [-1..1] (left->right)
rl.GAMEPAD_XBOX_AXIS_LEFT_Y  = 1   -- [-1..1] (up->down)
rl.GAMEPAD_XBOX_AXIS_RIGHT_X = 3   -- [-1..1] (left->right)
rl.GAMEPAD_XBOX_AXIS_RIGHT_Y = 4   -- [-1..1] (up->down)
rl.GAMEPAD_XBOX_AXIS_LT      = 2   -- [-1..1] (pressure-level)
rl.GAMEPAD_XBOX_AXIS_RT      = 5   -- [-1..1] (pressure-level)
--#else
--rl.GAMEPAD_XBOX_AXIS_LEFT_X  = 0   -- [-1..1] (left->right)
--rl.GAMEPAD_XBOX_AXIS_LEFT_Y  = 1   -- [1..-1] (up->down)
--rl.GAMEPAD_XBOX_AXIS_RIGHT_X = 2   -- [-1..1] (left->right)
--rl.GAMEPAD_XBOX_AXIS_RIGHT_Y = 3   -- [1..-1] (up->down)
--rl.GAMEPAD_XBOX_AXIS_LT      = 4   -- [-1..1] (pressure-level)
--rl.GAMEPAD_XBOX_AXIS_RT      = 5   -- [-1..1] (pressure-level)
--#endif

-- Some Basic Colors
-- NOTE: Custom raylib color palette for amazing visuals on WHITE background
rl.LIGHTGRAY  = { 200, 200, 200, 255 }   -- Light Gray
rl.GRAY       = { 130, 130, 130, 255 }   -- Gray
rl.DARKGRAY   = { 80, 80, 80, 255 }      -- Dark Gray
rl.YELLOW     = { 253, 249, 0, 255 }     -- Yellow
rl.GOLD       = { 255, 203, 0, 255 }     -- Gold
rl.ORANGE     = { 255, 161, 0, 255 }     -- Orange
rl.PINK       = { 255, 109, 194, 255 }   -- Pink
rl.RED        = { 230, 41, 55, 255 }     -- Red
rl.MAROON     = { 190, 33, 55, 255 }     -- Maroon
rl.GREEN      = { 0, 228, 48, 255 }      -- Green
rl.LIME       = { 0, 158, 47, 255 }      -- Lime
rl.DARKGREEN  = { 0, 117, 44, 255 }      -- Dark Green
rl.SKYBLUE    = { 102, 191, 255, 255 }   -- Sky Blue
rl.BLUE       = { 0, 121, 241, 255 }     -- Blue
rl.DARKBLUE   = { 0, 82, 172, 255 }      -- Dark Blue
rl.PURPLE     = { 200, 122, 255, 255 }   -- Purple
rl.VIOLET     = { 135, 60, 190, 255 }    -- Violet
rl.DARKPURPLE = { 112, 31, 126, 255 }    -- Dark Purple
rl.BEIGE      = { 211, 176, 131, 255 }   -- Beige
rl.BROWN      = { 127, 106, 79, 255 }    -- Brown
rl.DARKBROWN  = { 76, 63, 47, 255 }      -- Dark Brown

rl.WHITE      = { 255, 255, 255, 255 }   -- White
rl.BLACK      = { 0, 0, 0, 255 }         -- Black
rl.BLANK      = { 0, 0, 0, 0 }           -- Blank (Transparent)
rl.MAGENTA    = { 255, 0, 255, 255 }     -- Magenta
rl.RAYWHITE   = { 245, 245, 245, 255 }   -- My own White (raylib logo)

function rl.Vector2(...)
    return ffi.new("Vector2", ...)
end

function rl.Vector3(...)
    return ffi.new("Vector3", ...)
end

function rl.Vector4(...)
    return ffi.new("Vector4", ...)
end

function rl.Quaternion(...)
    return ffi.new("Quaternion", ...)
end

function rl.Matrix(...)
    return ffi.new("Matrix", ...)
end

function rl.Color(...)
    return ffi.new("Color", ...)
end

function rl.Rectangle(...)
    return ffi.new("Rectangle", ...)
end

function rl.Image(...)
    return ffi.new("Image", ...)
end

function rl.Texture2D(...)
    return ffi.new("Texture2D", ...)
end

function rl.Texture(...)
    return ffi.new("Texture", ...)
end

function TextureCubemap(...)
    return ffi.new("TextureCubemap", ...)
end

function rl.RenderTexture2D(...)
    return ffi.new("RenderTexture2D", ...)
end

function RenderTexture(...)
    return ffi.new("Vector3", ...)
end

function rl.NPatchInfo(...)
    return ffi.new("NPatchInfo", ...)
end

function rl.CharInfo(...)
    return ffi.new("CharInfo", ...)
end

function rl.Font(...)
    return ffi.new("Font", ...)
end

function rl.Camera3D(...)
    return ffi.new("Camera3D", ...)
end

function rl.Camera(...)
    return ffi.new("Camera", ...)
end

function rl.Camera2D(...)
    return ffi.new("Camera2D", ...)
end

function rl.Mesh(...)
    return ffi.new("Mesh", ...)
end

function rl.Shader(...)
    return ffi.new("Shader", ...)
end

function rl.MaterialMap(...)
    return ffi.new("MaterialMap", ...)
end

function rl.Material(...)
    return ffi.new("Material", ...)
end

function rl.Transform(...)
    return ffi.new("Transform", ...)
end

function rl.BoneInfo(...)
    return ffi.new("BoneInfo", ...)
end

function rl.Model(...)
    return ffi.new("Model", ...)
end

function rl.ModelAnimation(...)
    return ffi.new("ModelAnimation", ...)
end

function rl.Ray(...)
    return ffi.new("Ray", ...)
end

function rl.RayHitInfo(...)
    return ffi.new("RayHitInfo", ...)
end

function rl.BoundingBox(...)
    return ffi.new("BoundingBox", ...)
end

function rl.Wave(...)
    return ffi.new("Wave", ...)
end

function rl.rAudioBuffer(...)
    return ffi.new("rAudioBuffer", ...)
end

function rl.AudioStream(...)
    return ffi.new("AudioStream", ...)
end

function rl.Sound(...)
    return ffi.new("Sound", ...)
end

function rl.Music(...)
    return ffi.new("Music", ...)
end

function rl.VrDeviceInfo(...)
    return ffi.new("VrDeviceInfo", ...)
end

function rl.GetRandomValue(...)
    return math.random(...)
end

return rl
