defmodule Block do
  @derive Jason.Encoder
  defstruct type: nil, name: nil, script: nil, meta: %{}

  def from_map(%{
        type: type,
        name: name,
        script: script,
        meta: meta
      }) do
    %Block{
      type: type,
      name: name,
      script: script,
      meta: meta
    }
  end

  def from_map(%{"name" => name, "script" => script, "type" => type, "meta" => meta}) do
    %Block{
      type: type,
      name: name,
      script: script,
      meta: meta
    }
  end
end
