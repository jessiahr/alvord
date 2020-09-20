defmodule Canvas do
  # https://gist.github.com/rlipscombe/5f400451706efde62acbbd80700a6b7c
  # https://arifishaq.files.wordpress.com/2017/12/wxerlang-getting-started.pdf
  @behaviour :wx_object

  @title "Canvas Example"
  @size {500, 100}

  def start_link() do
    :wx_object.start_link(__MODULE__, [], [])
  end

  def init(args \\ []) do
    wx = :wx.new()
    frame = :wxFrame.new(wx, -1, @title, size: @size)
    :wxFrame.connect(frame, :size)
    :wxFrame.connect(frame, :close_window)

    panel = :wxPanel.new(frame, [])
    :wxPanel.connect(panel, :paint, [:callback])
    # equal = :wxButton.new(panel, 11, label: '=')
    text = :wxTextCtrl.new(panel, 12, value: "text")
    :wxFrame.show(frame)

    state = %{panel: panel}
    {frame, state}
  end

  def handle_event({:wx, _, _, _, {:wxSize, :size, size, _}}, state = %{panel: panel}) do
    :wxPanel.setSize(panel, size)
    {:noreply, state}
  end

  # def handle_event({:wx, _, _, _, {:wxClose, :close_window}}, state) do
  #   {:stop, :normal, state}
  # end

  # def handle_sync_event({:wx, _, _, _, {:wxPaint, :paint}}, _, state = %{panel: panel}) do
  #   brush = :wxBrush.new
  #   :wxBrush.setColour(brush, {255, 255, 255, 255})

  #   dc = :wxPaintDC.new(panel)
  #   :wxDC.setBackground(dc, brush)
  #   :wxDC.clear(dc)
  #   :wxPaintDC.destroy(dc)
  #   :ok
  # end
end
