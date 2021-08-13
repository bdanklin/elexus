defmodule ElexusHub do
  @moduledoc """
  An unofficial wrapper for the Wacraft portion of the [ElexusHubHub API](https://elexushubhub.co/wow-classic)
  """
  @doc """
  Returns the current phase details.

  ## Examples

      iex> ElexusHub.phase()
      %{
        contentPhase: 1,
        description: "Karazhan, Gruul's and Magtheridon's Lair",
        releaseDate: "2021-06-01T00:00:00.000Z"
      }


  """
  @spec phase :: map()
  def phase() do
    "content/active"
    |> send_get()
  end

  @doc """
  Returns the given phase details as a map, the phase must be an integer from `1` to `5`.

  ## Examples

      iex> ElexusHub.phase(3)
      %{
        contentPhase: 1,
        description: "Battle for Mount Hyjal and Black Temple",
        releaseDate: nil
      }

      iex> ElexusHub.phase(6)
      nil

      iex> ElexusHub.phase("hello")
      nil

  """
  @spec phase(integer()) :: map()
  def phase(arg) do
    "content"
    |> send_get()
    |> Enum.filter(&(Map.get(&1, :contentPhase) == arg))
    |> List.first()
  end

  @doc """
  Returns all WoW classic phases as a list of maps.

  ## Examples

      iex> ElexusHub.phases()
      [
        %{
          contentPhase: 1,
          description: "Karazhan, Gruul's and Magtheridon's Lair",
          releaseDate: "2021-06-01T00:00:00.000Z"
        },
        %{
          contentPhase: 2,
          description: "Serpent Shrine Cavern and Tempest Keep",
          releaseDate: nil
        },
        %{
          contentPhase: 3,
          description: "Battle for Mount Hyjal and Black Temple",
          releaseDate: nil
        },
        %{contentPhase: 4, description: "Zul'Aman", releaseDate: nil},
        %{
          contentPhase: 5,
          description: "Isle of Quel'Danas, Magister's Terrace and Sunwell",
          releaseDate: nil
        }
      ]


      iex> ElexusHub.phase(6)
      nil

      iex> ElexusHub.phase("hello")
      nil

  """
  @spec phases :: list()
  def phases() do
    "content"
    |> send_get()
  end

  @doc """
  Returns a map of profession in a list.

  ##Examples

      iex> ElexusHub.professions()
      [
        %{
          icon: "https://render-classic-us.worldofwarcraft.com/icons/56/trade_alchemy.jpg",
          name: "Alchemy"
        },
        %{
          icon: "https://render-classic-us.worldofwarcraft.com/icons/56/trade_blacksmithing.jpg",
          name: "Blacksmithing"
        },
        %{
          icon: "https://render-classic-us.worldofwarcraft.com/icons/56/inv_misc_food_15.jpg",
          name: "Cooking"
        },
        %{
          icon: "https://render-classic-us.worldofwarcraft.com/icons/56/trade_engraving.jpg",
          name: "Enchanting"
        },
        %{
          icon: "https://render-classic-us.worldofwarcraft.com/icons/56/trade_engineering.jpg",
          name: "Engineering"
        }...
      ]
  """
  @spec professions :: list()
  def professions() do
    ~s(crafting/professions)
    |> send_get()
  end

  @doc """

  ## Examples

      iex> ElexusHub.item_craft_deals("netherwind", "alliance", 1)
      [
        %{
          amount: [5, 5],
          category: "Alchemy",
          contentPhase: 1,
          createdByCosts: 417881,
          icon: "inv_potion_127",
          itemId: 22844,
          itemProfit: 5409390,
          name: "Major Nature Protection Potion",
          profit: 4991509,
          reagents: [
            %{amount: 1, itemId: 21886},
            %{amount: 3, itemId: 22793},
            %{amount: 5, itemId: 18256}
          ],
          recipes: [22922],
          requiredSkill: 360,
          uniqueName: "major-nature-protection-potion-22844"
        }
      ]

  """

  @spec item_craft_deals(String.t(), String.t(), integer(), integer(), integer()) :: map()
  def item_craft_deals(server, faction \\ "alliance", limit \\ 4, skip \\ 0, min_quantity \\ 3) do
    ~s(crafting/#{server}-#{faction}/deals)
    |> send_get([], %{limit: limit, skip: skip, min_quantity: min_quantity})
  end

  @doc """
  Returns information about the materials required to make the selected item and what that item can be made into.

  ## Examples

      iex> ElexusHub.item_crafts("netherwind", "alliance", 24261)
      %{
        itemId: 24261,
        name: "Whitemend Pants",
        reagentFor: [],
        slug: "netherwind-alliance",
        uniqueName: "whitemend-pants",
        createdBy: [
          recipes: [24308],
          requiredSkill: 375,
          %{
            amount: [1, 1],
            category: "Tailoring",
            contentPhase: 1,
            reagents: [
              %{
                amount: 10,
                icon: "https://wow.zamimg.com/images/wow/icons/large/inv_fabric_moonrag_primal.jpg",
                itemId: 21845,
                marketValue: 414141,
                name: "Primal Mooncloth",
                uniqueName: "primal-mooncloth",
                vendorPrice: nil
              },
              %{
                amount: 5,
                icon: "https://wow.zamimg.com/images/wow/icons/large/spell_nature_lightningoverload.jpg",
                itemId: 23571,
                marketValue: 805764,
                name: "Primal Might",
                uniqueName: "primal-might",
                vendorPrice: nil
              },
              %{
                amount: 1,
                contentPhase: 1,
                icon: "https://wow.zamimg.com/images/wow/icons/large/inv_elemental_primal_nether.jpg",
                itemId: 23572,
                marketValue: nil,
                name: "Primal Nether",
                uniqueName: "primal-nether",
                vendorPrice: nil
              }
            ]
          }
        ]
      }
  """

  @spec item_crafts(String.t(), String.t(), String.t()) :: map()
  def item_crafts(server, faction \\ "alliance", item_id) do
    ~s(crafting/#{server}-#{faction}/#{item_id})
    |> send_get()
  end

  @doc false
  @spec item_deals(
          String.t(),
          String.t(),
          integer(),
          integer(),
          integer(),
          boolean(),
          String.t()
        ) ::
          list()
  def item_deals(
        server,
        faction \\ "alliance",
        limit \\ 4,
        skip \\ 0,
        min_quantity \\ 3,
        relative \\ false,
        compare_with \\ ""
      ) do
    ~s(items/#{server}-#{faction}/deals)
    |> send_get([], %{
      limit: limit,
      skip: skip,
      min_quantity: min_quantity,
      relative: relative,
      compare_with: compare_with
    })
  end

  def item_details(
        server,
        faction \\ "alliance",
        item_id
      ) do
    ~s(items/#{server}-#{faction}/#{item_id})
    |> send_get()
  end

  @doc false
  def items(server, faction) do
    ~s(items/#{server}-#{faction})
    |> send_get()
  end

  @doc false
  def item_prices(server, faction, item_id) do
    ~s(items/#{server}-#{faction}/#{item_id}/prices)
    |> send_get()
  end

  @doc """
  Returns information about a given item id.

  ## Examples

      iex>ElexusHub.item(22265)
      %{
        icon: "https://wow.zamimg.com/images/wow/icons/large/inv_valentinescard02.jpg",
        itemId: 22265,
        itemLevel: 1,
        itemLink: "|cffffffff|Hitem:22265::::::::::0|h[Lovingly Composed Letter]|h|r",
        name: "Lovingly Composed Letter",
        requiredLevel: 1,
        sellPrice: 0,
        tags: ["Common", "Miscellaneous"],
        tooltip: [
          %{format: "Common", label: "Lovingly Composed Letter"},
          %{format: "Misc", label: "Item Level 1"},
          %{label: "Quest Item"},
          %{label: "Unique"}
        ],
        uniqueName: "lovingly-composed-letter",
        vendorPrice: nil
      }

  """
  def item(item_id) do
    ~s(item/#{item_id})
    |> send_get()
  end

  @doc """
  Returns a map of all servers in a list.

  ## Examples

      iex> ElexusHub.servers()
      [
        %{name: "Heartseeker", region: "US", slug: "heartseeker"},
        %{name: "Heartstriker", region: "EU", slug: "heartstriker"},
        %{name: "Herod", region: "US", slug: "herod"},
        %{name: "Hydraxian Waterlords", region: "EU", slug: "hydraxian-waterlords"},
        %{name: "Incendius", region: "US", slug: "incendius"},
        %{name: "Judgement", region: "EU", slug: "judgement"},
        %{name: "Kirtonos", region: "US", slug: "kirtonos"},
        %{name: "Kromcrush", region: "US", slug: "kromcrush"},
        %{name: "Kurinnaxx", region: "US", slug: "kurinnaxx"},
        %{name: "Lakeshire", region: "EU", slug: "lakeshire"},
        %{name: "Loatheb", region: "US", slug: "loatheb"},
        %{name: "Lucifron", region: "EU", slug: "lucifron"},
        %{name: "Mandokir", region: "EU", ...},
        %{name: "Mankrik", ...},
        %{...},
        ...
      ]

  """
  def servers() do
    ~s(servers/full)
    |> send_get()
  end

  @doc """
  Returns current World of Wacraft news from Wowhead. Accepts a requested amount of articles, defaults to 4.

  ## Examples

      iex> ElexusHub.news(count)
      [
        %{
          categories: ["TBC"],
          content: "An update to the Burning Cr...",
          guid: "https://www.wowhead.com/news=323762",
          isoDate: "2021-08-11T22:43:00.000Z",
          link: "https://www.wowhead.com/news=323762/updates-on...",
          pubDate: "Wed, 11 Aug 2021 17:43:00 -0500",
          title: "Updates on Burning Crusade Classic PTR - Arena Reward Cutoffs and Whi..."
        }
      ]


  """

  def news(per_chunk \\ 4) do
    ~s(news)
    |> send_get([], %{limit: per_chunk})
  end

  @doc """
  Fuzzy item search. Note the misspelled item name in the example.

  ## Examples

      iex>ElexusHub.search("Ironfow", 1, 0.8)
      [
        %{
          :itemId => 11684,
          :name => "Ironfoe",
          :uniqueName => "ironfoe",
          "imgUrl" => "https://wow.zamimg.com/images/wow/icons/large/spell_frost_frostbrand.jpg"
        }
      ]

  """
  def search(query, limit \\ 10, threshold \\ 0.4) do
    ~s(search)
    |> send_get([], %{query: query, limit: limit, threshold: threshold})
  end

  @doc """
  Fuzzy item search for only the beginning of the string. Use for autocomplete, etc

  ## Examples

      iex> ElexusHub.suggestions("devi", 3)
      [
        %{
          :itemId => 6522,
          :name => "Deviate Fish",
          :uniqueName => "deviate-fish",
          "imgUrl" => "https://wow.zamimg.com/images/wow/icons/large/inv_misc_monsterhead_01.jpg",
          "type" => "Consumable"
        },
        %{
          :itemId => 6443,
          :name => "Deviate Hide",
          :uniqueName => "deviate-hide",
          "imgUrl" => "https://wow.zamimg.com/images/wow/icons/large/inv_misc_pelt_wolf_ruin_03.jpg",
          "type" => "Quest"
        },
        %{
          :itemId => 6470,
          :name => "Deviate Scale",
          :uniqueName => "deviate-scale",
          "imgUrl" => "https://wow.zamimg.com/images/wow/icons/large/inv_misc_monsterscales_02.jpg",
          "type" => "Trade Goods"
        }
      ]

  """
  def suggestions(query, limit \\ 10) do
    ~s(search/suggestions)
    |> send_get([], %{query: query, limit: limit})
  end

  ########
  # Private
  ########

  defp bangify({:ok, body}), do: body
  defp bangify({:error, reason}), do: raise(reason)

  defp send_get(endpoint, options \\ [], params \\ %{})

  defp send_get(endpoint, options, params) do
    Fish.ElexusHub.Base.get(endpoint, options, params: params)
    |> return_get()
  end

  defp return_get({:ok, %{body: body, status_code: 200}}), do: body

  defp return_get({:ok, %HTTPoison.Response{body: %{reason: reason}, status_code: 404}}),
    do: {:error, reason}
end
