defmodule DontTruckAroundWeb.Config do
  @moduledoc """
  A module to handle application configuration.
  """

  def google_maps_api_key do
    Application.get_env(:dont_truck_around, :google_maps_api_key)
  end
end
