defmodule DontTruckAround.Impl.ApiService do
  use Tesla

  alias NimbleCSV.RFC4180, as: CSV

  plug(Tesla.Middleware.BaseUrl, "https://data.sfgov.org/api/views")
  plug(Tesla.Middleware.JSON)

  @office_space_endpoint "/g8m3-pdis/rows.csv"
  @food_truck_endpoint "/rqzj-sfat/rows.csv"

  def fetch_food_truck_data do
    fetch_and_parse_csv(@food_truck_endpoint)
  end

  def fetch_office_data do
    fetch_and_parse_csv(@office_space_endpoint)
  end

  defp fetch_and_parse_csv(url) do
    case get(url) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, parse_csv(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_csv(csv_content) do
    [header | rows] = CSV.parse_string(csv_content, skip_headers: false)

    rows
    |> Enum.map(&(Enum.zip(header, &1) |> Enum.into(%{})))
  end
end
