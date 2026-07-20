defmodule Ebloved.ClusterData.PrometheusTest do
  use ExUnit.Case, async: true

  alias Ebloved.ClusterData.Prometheus

  describe "parse_value/1" do
    test "parses a numeric string into a rounded float" do
      assert {:ok, 12.5} = Prometheus.parse_value("12.5")
    end

    test "degrades non-numeric Prometheus values (e.g. NaN) to an error instead of raising" do
      assert {:error, _} = Prometheus.parse_value("NaN")
    end

    test "degrades an empty value to an error instead of raising" do
      assert {:error, _} = Prometheus.parse_value("")
    end
  end
end
