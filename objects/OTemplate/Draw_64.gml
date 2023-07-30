if (screenshotMode)
{
	exit;
}

var _windowWidth = window_get_width();

var _text = "FPS: " + string(fps) + " (" + string(fps_real) + ")";
draw_text_color(_windowWidth - string_width(_text) - 8, 8, _text,
	c_silver, c_silver, c_silver, c_silver, 1.0);

gui.SetPosition(8, 8)
	.Checkbox(guiShow, {
		Label: "Show UI (F1)",
		OnChange: method(self, function (_value) { guiShow = _value; }),
	})
	.Newline();

if (guiShow)
{
	gui.Slider("camera-fov", fov, {
			Label: "Camera FoV",
			Min: 1,
			Max: 90,
			Round: true,
			OnChange: method(self, function (_value) { fov = _value; }),
		})
		.Newline()
		;
}
