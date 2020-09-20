defmodule Block do
  @derive Jason.Encoder
  defstruct type: nil, name: nil, script: nil

  def from_map(%{
        type: type,
        name: name,
        script: script
      }) do
    %Block{
      type: type,
      name: name,
      script: script
    }
  end

  def from_map(%{"name" => name, "script" => script, "type" => type}) do
    %Block{
      type: type,
      name: name,
      script: script
    }
  end
end
