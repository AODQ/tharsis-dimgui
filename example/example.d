module example;

import std.exception;
import std.stdio;

import std.algorithm : min;
import std.exception : enforce;
import std.file;
import std.functional : toDelegate;
import std.path;
import std.stdio : stderr;
import std.string : format;

import deimos.glfw.glfw3;

import glad.gl.enums;
import glad.gl.ext;
import glad.gl.funcs;
import glad.gl.loader;
import glad.gl.types;

import glwtf.input;
import glwtf.window;

import imgui;

import window;

// imgui states
bool  checked1  = false;
bool  checked2  = false;
bool  checked3  = true;
bool  checked4  = false;
float value1    = 50.0;
float value2    = 30.0;
int scrollarea1 = 0;
int scrollarea2 = 0;

int mscroll = 0;

int windowWidth, windowHeight;

/**
    This tells OpenGL what area of the available area we are
    rendering to. In this case, we change it to match the
    full available area. Without this function call resizing
    the window would have no effect on the rendering.
*/
void onWindowResize(int width, int height)
{
    // bottom-left position.
    enum int x = 0;
    enum int y = 0;

    /**
        This function defines the current viewport transform.
        It defines as a region of the window, specified by the
        bottom-left position and a width/height.

        Note about the viewport transform:
        It is the process of transforming vertex data from normalized
        device coordinate space to window space. It specifies the
        viewable region of a window.
    */
    glViewport(x, y, width, height);

    windowWidth = width;
    windowHeight = height;
}

int main(string[] args)
{
    int width = 1024, height = 768;

    auto window = createWindow("imgui", WindowMode.windowed, width, height);

    auto onScroll = delegate void (double hOffset, double vOffset)
    {
        mscroll = -cast(int)vOffset;
    };

    window.on_scroll.strongConnect(onScroll);

    // trigger initial viewport transform.
    onWindowResize(width, height);

    window.on_resize.strongConnect(toDelegate(&onWindowResize));

    // Enable vertical sync (on cards that support it)
    glfwSwapInterval(1);

    string fontPath = thisExePath().dirName().buildPath("../").buildPath("DroidSans.ttf");

    enforce(imguiInit(fontPath));

    glClearColor(0.8f, 0.8f, 0.8f, 1.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);

    while (!glfwWindowShouldClose(window.window))
    {
        renderGui(window);

        /* Swap front and back buffers. */
        window.swap_buffers();

        /* Poll for and process events. */
        glfwPollEvents();

        if (window.is_key_down(GLFW_KEY_ESCAPE))
            glfwSetWindowShouldClose(window.window, true);
    }

    // Clean UI
    imguiDestroy();

    return 0;
}

void renderGui(Window window)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Mouse states
    ubyte mousebutton = 0;
    double mouseX;
    double mouseY;
    glfwGetCursorPos(window.window, &mouseX, &mouseY);

    int mousex = cast(int)mouseX;
    int mousey = cast(int)mouseY;

    mousey = windowHeight - mousey;
    int leftButton   = glfwGetMouseButton(window.window, GLFW_MOUSE_BUTTON_LEFT);
    int rightButton  = glfwGetMouseButton(window.window, GLFW_MOUSE_BUTTON_RIGHT);
    int middleButton = glfwGetMouseButton(window.window, GLFW_MOUSE_BUTTON_MIDDLE);
    int toggle       = 0;

    if (leftButton == GLFW_PRESS)
        mousebutton |= MouseButton.left;

    imguiBeginFrame(mousex, mousey, mousebutton, mscroll);

    if (mscroll != 0)
        mscroll = 0;

    imguiBeginScrollArea("Scroll area", 10, 10, windowWidth / 5, windowHeight - 20, &scrollarea1);
    imguiSeparatorLine();
    imguiSeparator();

    imguiButton("Button");
    imguiButton("Disabled button", Enabled.no);
    imguiItem("Item");
    imguiItem("Disabled item", Enabled.no);
    toggle = imguiCheck("Checkbox", checked1);

    if (toggle)
        checked1 = !checked1;

    toggle = imguiCheck("Disabled checkbox", checked2, Enabled.no);

    if (toggle)
        checked2 = !checked2;

    toggle = imguiCollapse("Collapse", "subtext", checked3);

    if (checked3)
    {
        imguiIndent();
        imguiLabel("Collapsable element");
        imguiUnindent();
    }

    if (toggle)
        checked3 = !checked3;

    toggle = imguiCollapse("Disabled collapse", "subtext", checked4, Enabled.no);

    if (toggle)
        checked4 = !checked4;

    imguiLabel("Label");
    imguiValue("Value");
    imguiSlider("Slider", &value1, 0.0, 100.0, 1.0f);
    imguiSlider("Disabled slider", &value2, 0.0, 100.0, 1.0f, Enabled.no);
    imguiIndent();
    imguiLabel("Indented");
    imguiUnindent();
    imguiLabel("Unindented");

    imguiEndScrollArea();

    imguiBeginScrollArea("Scroll area", 20 + windowWidth / 5, 500, windowWidth / 5, windowHeight - 510, &scrollarea2);
    imguiSeparatorLine();
    imguiSeparator();

    foreach (i; 0 .. 100)
        imguiLabel("A wall of text");

    imguiEndScrollArea();
    imguiEndFrame();

    imguiDrawText(30 + windowWidth / 5 * 2, windowHeight - 20, TextAlign.left, "Free text", RGBA(32, 192, 32, 192));
    imguiDrawText(30 + windowWidth / 5 * 2 + 100, windowHeight - 40, TextAlign.right, "Free text", RGBA(32, 32, 192, 192));
    imguiDrawText(30 + windowWidth / 5 * 2 + 50, windowHeight - 60, TextAlign.center, "Free text", RGBA(192, 32, 32, 192));

    imguiDrawLine(30 + windowWidth / 5 * 2, windowHeight - 80, 30 + windowWidth / 5 * 2 + 100, windowHeight - 60, 1.0f, RGBA(32, 192, 32, 192));
    imguiDrawLine(30 + windowWidth / 5 * 2, windowHeight - 100, 30 + windowWidth / 5 * 2 + 100, windowHeight - 80, 2.0, RGBA(32, 32, 192, 192));
    imguiDrawLine(30 + windowWidth / 5 * 2, windowHeight - 120, 30 + windowWidth / 5 * 2 + 100, windowHeight - 100, 3.0, RGBA(192, 32, 32, 192));

    imguiDrawRoundedRect(30 + windowWidth / 5 * 2, windowHeight - 240, 100, 100, 5.0, RGBA(32, 192, 32, 192));
    imguiDrawRoundedRect(30 + windowWidth / 5 * 2, windowHeight - 350, 100, 100, 10.0, RGBA(32, 32, 192, 192));
    imguiDrawRoundedRect(30 + windowWidth / 5 * 2, windowHeight - 470, 100, 100, 20.0, RGBA(192, 32, 32, 192));

    imguiDrawRect(30 + windowWidth / 5 * 2, windowHeight - 590, 100, 100, RGBA(32, 192, 32, 192));
    imguiDrawRect(30 + windowWidth / 5 * 2, windowHeight - 710, 100, 100, RGBA(32, 32, 192, 192));
    imguiDrawRect(30 + windowWidth / 5 * 2, windowHeight - 830, 100, 100, RGBA(192, 32, 32, 192));

    imguiRender(windowWidth, windowHeight);
}
