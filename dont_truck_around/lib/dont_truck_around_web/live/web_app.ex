defmodule DontTruckAroundWeb.Live.WebApp do
  use DontTruckAroundWeb, :live_view

  alias DontTruckAround.Impl.ApiService

  @initial_state %{
    food_trucks: [],
    filters: %{"vegetarian" => false, "vegan" => false, "gluten_free" => false}
  }

  def mount(_params, _session, socket) do
    {:noreply, initial_socket} =
      socket
      |> assign(@initial_state)
      |> fetch_and_assign_food_trucks()

    {:ok, initial_socket}
  end

  def render(assigns) do
    trucks_html = ~H"""
    <div>
      <h1>Food Truck Finder</h1>

      <form phx-submit="submit_filters">
        <label>
          Vegetarian:
          <input
            type="checkbox"
            name="filters[vegetarian]"
            value="true"
            checked={@filters["vegetarian"]}
          />
        </label>
        <label>
          Vegan:
          <input type="checkbox" name="filters[vegan]" value="true" checked={@filters["vegan"]} />
        </label>
        <label>
          Gluten-Free:
          <input
            type="checkbox"
            name="filters[gluten_free]"
            value="true"
            checked={@filters["gluten_free"]}
          />
        </label>
        <button type="submit">Apply Filters</button>
      </form>

      <div id="truck-list">
        <%= if Enum.empty?(@food_trucks) do %>
          <p>No food trucks found.</p>
        <% else %>
          <table class="truck-table">
            <thead>
              <tr>
                <th>Applicant</th>
                <th>Food Items</th>
                <th>Location</th>
                <th>Facility Type</th>
                <th>Latitude</th>
                <th>Longitude</th>
              </tr>
            </thead>
            <tbody>
              <%= for truck <- @food_trucks do %>
                <tr class="truck">
                  <td><%= truck["Applicant"] %></td>
                  <td><%= truck["FoodItems"] %></td>
                  <td><%= truck["LocationDescription"] %></td>
                  <td><%= truck["FacilityType"] %></td>
                  <td><%= truck["Latitude"] %></td>
                  <td><%= truck["Longitude"] %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>
      </div>
      
      <div id="google-maps">
        <!-- Google Maps integration here -->
      </div>
    </div>
    """
  end

  def handle_event("submit_filters", %{"filters" => filters}, socket) do
    socket |> assign(filters: filters) |> fetch_and_assign_food_trucks()
  end

  def fetch_and_assign_food_trucks(socket) do
    case ApiService.fetch_food_truck_data() do
      {:ok, trucks} ->
        # TODO: filtering not working right now, due to data set not containing type of food
        # filtered_trucks = filter_food_trucks(trucks, socket.assigns.filters)
        filtered_trucks =
          trucks
          # |> Enum.filter(&filter_truck/1)
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

        {:noreply, assign(socket, food_trucks: filtered_trucks)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  defp filter_truck(truck) do
    # TODO: will need to see if there are any other ways to tell if a food truck is approved/active
    # currently the dataset shows nil for all trucks, must be a bug on their end
    # truck["Approved"] == "TRUE"
  end

  defp filter_food_trucks(trucks, filters) do
    trucks
    |> Enum.filter(fn truck ->
      matches_filters?(truck, filters)
    end)
  end

  defp matches_filters?(truck, filters) do
    Enum.all?(filters, fn {filter_key, filter_value} ->
      Map.get(truck, String.to_atom(filter_key)) == filter_value
    end)
  end
end
