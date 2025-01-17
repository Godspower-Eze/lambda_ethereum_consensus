defmodule ConfigUtils do
  @moduledoc """
  Utilities for parsing configs and presets.
  """
  @forks ["phase0", "altair", "bellatrix", "capella", "deneb"]

  def load_config_from_file!(path) do
    path
    |> File.read!()
    |> String.replace(~r/(0x[0-9a-fA-F]+)/, "'\\g{1}'")
    |> YamlElixir.read_from_string!()
    |> Stream.map(fn
      {k, "0x" <> hash} -> {k, Base.decode16!(hash, case: :mixed)}
      e -> e
    end)
    |> Enum.into(%{})
  end

  def load_preset_from_dir!(path) do
    # TODO: we should return the merged preset for each fork here
    @forks
    |> Stream.map(&Path.join([path, "#{&1}.yaml"]))
    |> Stream.map(&YamlElixir.read_from_file!/1)
    # The order is to ensure that the later forks override the earlier ones.
    |> Enum.reduce(&Map.merge(&2, &1))
  end

  def parse_config("mainnet"), do: MainnetConfig
  def parse_config("sepolia"), do: SepoliaConfig
  def parse_config("minimal"), do: MinimalConfig
  def parse_config("gnosis"), do: GnosisConfig
  def parse_config(other), do: raise("Unknown config: #{other}")

  def parse_preset("mainnet"), do: MainnetPreset
  def parse_preset("minimal"), do: MinimalPreset
  def parse_preset("gnosis"), do: GnosisPreset
  def parse_preset(other), do: raise("Unknown preset: #{other}")
end
