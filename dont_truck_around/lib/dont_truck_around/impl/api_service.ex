defmodule DontTruckAround.Impl.ApiService do
  use Tesla

  alias NimbleCSV.RFC4180, as: CSV

  # Currently using the city of san fransico, but we could extend to other cities as well
  plug(Tesla.Middleware.BaseUrl, "https://data.sfgov.org/api/views")
  plug(Tesla.Middleware.JSON)

  # Endpoint for office density and spaces
  @office_space_endpoint "/g8m3-pdis/rows.csv"
  # Endpoint for registered food trucks in SF
  @food_truck_endpoint "/rqzj-sfat/rows.csv"

  @spec fetch_food_truck_data() :: {:error, any()} | {:ok, list()}
  def fetch_food_truck_data do
    fetch_and_parse_csv(@food_truck_endpoint)
  end

  @spec fetch_office_data() :: {:error, any()} | {:ok, list()}
  def fetch_office_data do
    # We are reading CSV for now as the endpoint takes way too long to finish, ideally we'd have our own DB
    office_data = read_csv_from_assets("office-data-sf.csv") |> parse_csv()
    {:ok, office_data}
  end

  defp read_csv(file_path) do
    file_path
    |> File.read!()
  end

  def read_csv_from_assets(file_name) do
    file_path = Path.join(["assets", file_name])
    read_csv(file_path)
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
