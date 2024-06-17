defmodule DontTruckAroundWeb.Live.WebApp do
  use DontTruckAroundWeb, :live_view

  alias DontTruckAround.Impl.ApiService

  @typedoc """
  Represents a geographic point with latitude and longitude.
  """
  @type geo_point :: {float(), float()}

  @typedoc """
  Represents a food truck location with its geographic coordinates and density.
  """
  @type food_truck_location :: %{
          lat: float(),
          lng: float(),
          density: integer()
        }

  @typedoc """
  Represents an office location with its geographic coordinates and foot traffic potential.
  """
  @type office_location :: %{
          lat: float(),
          lng: float(),
          foot_traffic: integer()
        }
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:targets, list_targets())}
  end

  def handle_event("update_targets", _params, socket) do
    {:noreply,
     socket
     |> push_event(
       "update_markers",
       %{data: list_targets()}
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 flex flex-col items-center">
      <!-- Header -->
      <header class="w-full bg-blue-600 text-white p-4 shadow-lg">
        <div class="max-w-7xl mx-auto flex justify-between items-center">
          <h1 class="text-3xl font-bold">Don't Truck Around!</h1>
        </div>
      </header>
      <main class="flex-grow w-full max-w-4xl mx-auto mt-8 px-4">
        <section class="bg-white p-6 rounded-lg shadow-md mb-8">
          <h2 class="text-2xl font-semibold mb-4">
            Want to know the best place to park your food truck?
          </h2>
          <p class="text-gray-700 mb-4">
            This website will help you find the best place to park your food truck based on office and neighborhood density. Just enter in an address and see where the nearest place to park is within 10 miles! Don't Truck Around, let us do it for you!
          </p>
          <p>
            Our current location we are using to determine best parking spots is lat: "37.7749", lng: "-122.4194"
          </p>
          <!-- <button -->
          <!--   phx-click="update_targets" -->
          <!--   class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-opacity-50" -->
          <!-- > -->
          <!--  -->
          <!-- </button> -->
        </section>
        <div
          id="googleMap"
          class="w-full bg-slate-100"
          style="height: 750px;"
          phx-hook="GMaps"
          phx-update="ignore"
          data-targets={Jason.encode!(@targets)}
        >
        </div>
      </main>
    </div>
    """
  end

  defp fetch_food_truck_data() do
    case ApiService.fetch_food_truck_data() do
      {:ok, trucks} ->
        trucks
        |> Enum.map(fn truck ->
          %{
            "Applicant" => truck["Applicant"],
            "FoodItems" => truck["FoodItems"],
            "LocationDescription" => truck["LocationDescription"],
            "FacilityType" => truck["FacilityType"],
            "Latitude" => truck["Latitude"],
            "Longitude" => truck["Longitude"]
          }
        end)

      {:error, reason} ->
        {:noreply, reason}
    end
  end

  defp fetch_office_data() do
    case ApiService.fetch_office_data() do
      {:ok, offices} ->
        offices
        |> Enum.map(fn office ->
          %{
            "Name" => office["DBA Name"],
            "Address" => office["Street Address"],
            "Zip" => office["Source Zipcode"],
            "City" => office["City"],
            "FootTraffic" => office["Analysis Neighborhoods"],
            "Latitude" => office["Latitude"],
            "Longitude" => office["Longitude"]
          }
        end)

      {:error, reason} ->
        {:noreply, reason}
    end
  end

  defp list_targets() do
    # TODO: Change to lat/lng from user input
    find_best_parking_locations(%{lat: "37.7749", lng: "-122.4194"})
    |> Enum.map(fn {lat, lng} ->
      %{
        lat: lat,
        lng: lng
      }
    end)
  end

  @doc """
  Calculates the foot traffic score for a given food truck location based on nearby offices.

  Returns an integer score.
  """
  @spec calculate_foot_traffic_score(
          offices :: [office_location],
          food_truck_location
        ) :: integer
  def calculate_foot_traffic_score(offices, food_truck) do
    Enum.reduce(offices, 0, fn office, acc ->
      distance_km =
        haversine_distance(
          {office["Latitude"], office["Longitude"]},
          {food_truck["Latitude"], food_truck["Longitude"]}
        )

      # Adjust the radius as needed
      if distance_km <= 10.0 do
        acc + office["FootTraffic"]
      else
        acc
      end
    end)
  end

  @doc """
  Finds the top 3 locations to park a food truck based on foot traffic within a 10-mile radius.

  Returns a list of `geo_point` representing the best parking locations.
  """
  @spec find_best_parking_locations(address :: geo_point) :: [geo_point]
  def find_best_parking_locations(address) do
    food_trucks = fetch_food_truck_data()
    offices = fetch_office_data()

    address_latlng = {address.lat, address.lng}
    # Filter food trucks within 30 miles of the address
    filtered_food_trucks =
      Enum.filter(food_trucks, fn truck ->
        (truck["Latitude"] != "0" || truck["Longitude"] != "0") &&
          haversine_distance(address_latlng, {truck["Latitude"], truck["Longitude"]}) <= 10.0
      end)

    # Filter offices within 30 miles of the address
    filtered_offices =
      Enum.filter(offices, fn office ->
        (office["Latitude"] != "0" || office["Longitude"] != "0") &&
          haversine_distance(address_latlng, {office["Latitude"], office["Longitude"]}) <= 10.0
      end)

    all_locations_with_scores =
      Enum.map(filtered_food_trucks, fn truck ->
        foot_traffic_score = calculate_foot_traffic_score(filtered_offices, truck)

        {foot_traffic_score, truck}
      end)

    top_locations =
      Enum.take(
        Enum.sort(all_locations_with_scores, fn {score1, _}, {score2, _} -> score1 >= score2 end),
        3
      )

    Enum.map(top_locations, fn {_score, truck} -> {truck["Latitude"], truck["Longitude"]} end)
  end

  defp haversine_distance({lat1, lng1}, {lat2, lng2}) do
    lat1 = String.to_float(lat1)
    lng1 = String.to_float(lng1)
    lat2 = String.to_float(lat2)
    lng2 = String.to_float(lng2)
    # Radius of the Earth in kilometers
    earth_radius = 6371.0

    delta_lat = to_radians(lat2 - lat1)
    delta_lng = to_radians(lng2 - lng1)

    a =
      :math.sin(delta_lat / 2.0) * :math.sin(delta_lat / 2.0) +
        :math.cos(to_radians(lat1)) * :math.cos(to_radians(lat2)) *
          :math.sin(delta_lng / 2.0) * :math.sin(delta_lng / 2.0)

    c = 2.0 * :math.atan2(:math.sqrt(a), :math.sqrt(1.0 - a))

    # Distance in kms
    earth_radius * c
  end

  defp to_radians(degrees) do
    degrees * :math.pi() / 180.0
  end
end
