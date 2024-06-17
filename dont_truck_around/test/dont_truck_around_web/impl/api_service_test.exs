defmodule DontTruckAround.Impl.ApiServiceTest do
  use ExUnit.Case, async: true
  import Mox

  alias DontTruckAround.Impl.ApiService

  setup :verify_on_exit!

  @food_truck_csv "applicant,address,fooditems\nTruck A,Address A,Burgers\nTruck B,Address B,Tacos"
  @office_space_csv "location,square_feet\nLocation A,1000\nLocation B,2000"

  describe "fetch_food_truck_data/1" do
    test "returns parsed CSV data on success" do
      DontTruckAround.Impl.MockHttpClient
      |> expect(:call, fn %{method: :get, url: "/rqzj-sfat/rows.csv"}, _opts ->
        {:ok, %Tesla.Env{status: 200, body: @food_truck_csv}}
      end)

      assert {:ok, result} = ApiService.fetch_food_truck_data()

      assert result == [
               %{"applicant" => "Truck A", "address" => "Address A", "fooditems" => "Burgers"},
               %{"applicant" => "Truck B", "address" => "Address B", "fooditems" => "Tacos"}
             ]
    end

    test "returns error on failure" do
      DontTruckAround.Impl.MockHttpClient
      |> expect(:call, fn %{method: :get, url: "/rqzj-sfat/rows.csv"}, _opts ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} = ApiService.fetch_food_truck_data()
    end
  end

  describe "fetch_office_data/1" do
    test "returns parsed CSV data on success" do
      DontTruckAround.Impl.MockHttpClient
      |> expect(:call, fn %{method: :get, url: "/g8m3-pdis/rows.csv"}, _opts ->
        {:ok, %Tesla.Env{status: 200, body: @office_space_csv}}
      end)

      assert {:ok, result} = ApiService.fetch_office_data()

      assert result == [
               %{"location" => "Location A", "square_feet" => "1000"},
               %{"location" => "Location B", "square_feet" => "2000"}
             ]
    end

    test "returns error on failure" do
      DontTruckAround.Impl.MockHttpClient
      |> expect(:call, fn %{method: :get, url: "/g8m3-pdis/rows.csv"}, _opts ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} = ApiService.fetch_office_data()
    end
  end
end
