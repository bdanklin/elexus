defmodule Elexus.Base do
  use HTTPoison.Base
  @moduledoc false

  @expected_fields ~w(imgUrl type categories content guid isoDate link pubDate title region slug reagentFor createdBy error reason recipes requiredSkill amount category createdByCosts itemProfit profit reagents contentPhase description releaseDate scannedAt icon itemId itemLevel itemLink name requiredLevel sellPrice server stats current historicalValue marketValue minBuyout numAuctions quantity lastUpdated previous historicalValue marketValue minBuyout numAuctions quantity tags tooltip uniqueName vendorPrice format label)
  @endpoint "https://api.nexushub.co/wow-classic/v1/"

  def process_request_url(url) do
    @endpoint <> url
  end

  def process_response_body(response) do
    response
    |> Jason.decode!()
    |> return()
  end

  defp return([_ | _] = list), do: Enum.map(list, &atomorphiform!(&1))
  defp return(%{} = map), do: atomorphiform!(map)

  defp atomorphiform!(map), do: Morphix.atomorphiform!(map, @expected_fields)
end
