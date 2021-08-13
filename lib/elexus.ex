defmodule Elexus do
  @moduledoc """
  An unofficial wrapper for the Wacraft portion of the [Nexus Hub API](https://Elexushub.co/wow-classic)
  """

  @doc """
  Returns information about the materials required to make the selected `item_id` and what that `item_id` can be made into. To receive pricing information at the same time, see `Elexus.craftable/3`

  ## Examples

      iex> Elexus.craftable(14530)
      %{
        itemId: 14530,
        name: "Heavy Runecloth Bandage",
        reagentFor: [],
        uniqueName: "heavy-runecloth-bandage"
        createdBy: [
          %{
            recipes: [],
            requiredSkill: 290
            category: "First Aid",
            amount: [1, 1],
            reagents: [
              %{
                amount: 2,
                contentPhase: 1,
                icon: "https://wow.zamimg.com/images/wow/icons/large/inv_fabric_purplefire_01.jpg",
                itemId: 14047,
                name: "Runecloth",
                uniqueName: "runecloth",
                vendorPrice: nil
              }
            ],
          }
        ],
      }

      iex> Elexus.craftable(item_without_crafting)
      %{
        createdBy: [],
        itemId: 12345,
        name: "Bijou's Belongings",
        reagentFor: [],
        uniqueName: "bijous-belongings"
      }

  """

  @spec craftable(integer()) :: map() | {:error, String.t()}
  def craftable(item_id) do
    ~s(crafting/#{item_id})
    |> send_get()
  end

  @doc """
  Returns information about the materials required to make the selected `item_id` and what that `item_id` can be made into, pricing is drawn from the given `realm` and `faction`.

  ## Examples

      iex> Elexus.craftable(24261, "netherwind", "alliance")
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

  @spec craftable(integer(), String.t(), String.t()) :: map() | {:error, String.t()}

  def craftable(item_id, server, faction) do
    ~s(crafting/#{server}-#{faction}/#{item_id})
    |> send_get()
  end

  @doc """

  Returns craftables currently identified as being profitable to craft. accepts the following options:

  - `limit:` Maximum items to return.
  - `skip:` Items to skip before returning.
  - `min_quantity:` Only return if `Enum.count/1` is greater than `:min_quantity`

  ## Examples

      iex> Elexus.craftable_deals("netherwind", "alliance", 1)
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

  @typedoc """
  Acceptable options for `Elexus.craftable_deals/3`
  """
  @type craftable_deals_opts ::
          {:limit, integer} | {:skip, integer()} | {:min_quantity, integer()}

  @spec craftable_deals(String.t(), String.t(), craftable_deals_opts()) :: map()

  def craftable_deals(server, faction, options)

  def craftable_deals(server \\ "netherwind", faction \\ "alliance", craftable_deals_opts \\ []) do
    ~s(crafting/#{server}-#{faction}/deals)
    |> send_get([], craftable_deals_opts)
  end

  @doc """
  Returns the current phase details.

  ## Examples

      iex> Elexus.phase()
      %{
        contentPhase: 1,
        description: "Karazhan, Gruul's and Magtheridon's Lair",
        releaseDate: "2021-06-01T00:00:00.000Z"
      }


  """
  @spec phase() :: map()
  def phase() do
    "content/active"
    |> send_get()
  end

  @doc """
  Returns the selected `phase` details.

  ## Examples

      iex> Elexus.phase(3)
      %{
        contentPhase: 1,
        description: "Battle for Mount Hyjal and Black Temple",
        releaseDate: nil
      }

      iex> Elexus.phase(6)
      nil

      iex> Elexus.phase("hello")
      nil

  """
  @spec phase(integer()) :: map()
  def phase(phase)

  def phase(arg) do
    "content"
    |> send_get()
    |> Enum.filter(&(Map.get(&1, :contentPhase) == arg))
    |> List.first()
  end

  @doc """
  Returns all WoW classic phases as a list of maps.

  ## Examples

      iex> Elexus.phases()
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


      iex> Elexus.phase(6)
      nil

      iex> Elexus.phase("hello")
      nil

  """
  @spec phases() :: list()
  def phases() do
    "content"
    |> send_get()
  end

  @doc """
  Returns a list containing all professions.

  ## Examples

      iex> Elexus.professions()
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
  @spec professions() :: list()
  def professions() do
    ~s(crafting/professions)
    |> send_get()
  end

  @typedoc """
  Acceptable options for `Elexus.item_deals/3`
  """
  @type item_deals_opt ::
          {:limit, integer()}
          | {:skip, integer()}
          | {:min_quantity, integer()}
          | {:relative, boolean()}
          | {:compare_with, String.t()}

  @spec item_deals(String.t(), String.t(), [item_deals_opt]) :: list()
  def item_deals(server, faction \\ "alliance", opts \\ []) do
    ~s(items/#{server}-#{faction}/deals)
    |> send_get([], opts)
  end

  @doc """
  Returns current and recent price information for the selected `item_id` in relation to the `realm` and `faction`.

  ## Examples

      iex> Elexus.item_pricing("netherwind", "alliance", 22844)
      %{
        icon: "https://wow.zamimg.com/images/wow/icons/large/inv_potion_127.jpg",
        itemId: 22844,
        itemLevel: 72,
        itemLink: "|cffffffff|Hitem:22844::::::::::0|h[Major Nature Protection Potion]|h|r",
        name: "Major Nature Protection Potion",
        requiredLevel: 60,
        sellPrice: 6000,
        server: "netherwind-alliance",
        stats: %{
          current: %{
            historicalValue: 69900,
            marketValue: 1250807,
            minBuyout: 1778000,
            numAuctions: 1,
            quantity: 5
          },
          lastUpdated: "2021-08-13T03:06:14.000Z",
          previous: %{
            historicalValue: 64950,
            marketValue: 1085116,
            minBuyout: 1776000,
            numAuctions: 2,
            quantity: 10
          }
        },
        tags: ["Common", "Consumable"],
        tooltip: [
          %{format: "Common", label: "Major Nature Protection Potion"},
          %{format: "Misc", label: "Item Level 72"},
          %{label: "Requires Level 60"},
          %{
            format: "Uncommon",
            label: "Use: Absorbs 2800 to 4000 nature damage.  Lasts 2 min. (2 Min Cooldown)"
          },
          %{label: "Max Stack: 5"},
          %{label: "Sell Price:"}
        ],
        uniqueName: "major-nature-protection-potion-22844",
        vendorPrice: nil
      }


  """
  @spec item(integer(), String.t(), String.t()) :: map()
  def item(item_id, server, faction \\ "alliance") do
    ~s(items/#{server}-#{faction}/#{item_id})
    |> send_get()
  end

  @doc false
  @spec items(String.t(), String.t()) :: list()
  def items(server, faction) do
    ~s(items/#{server}-#{faction})
    |> send_get()
  end

  @doc false
  @spec item_prices(integer(), String.t(), String.t()) :: map()
  def item_prices(item_id, server, faction) do
    ~s(items/#{server}-#{faction}/#{item_id}/prices)
    |> send_get()
  end

  @doc """
  Returns information about a given `item_id`.

  ## Examples

      iex> Elexus.item(22265)
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

      iex>Elexus.item(invalid_item_id)
      {:error, "Item Not Found"}

  """
  @spec item(integer()) :: map() | {:error, String.t()}
  def item(item_id) do
    ~s(item/#{item_id})
    |> send_get()
  end

  @doc """
  Returns a list containing information about all of the World of Wacraft realms.

  ## Examples

      iex> Elexus.servers()
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
  Returns the latest World of Wacraft news article from  [Wowhead](https://www.wowhead.com/).

  ## Examples

      iex> Elexus.news()
        %{
          categories: ["Blizzard"],
          content: "Two more corporate sponsors have removed their support from the Overwatch League in the wake of widespread allegations of sexual harassment and a discrimination lawsuit brought forth by the California Department of Fair Employment and Housing against Activision Blizzard. We previously saw T-Mobile and State Farm insurance reevaluating their partnerships, but now esports.gg has reported IBM and Kellogg's Cheez-It Grooves and Pringles Wavy withdrawing their support as well.",
          guid: "https://www.wowhead.com/news=323766",
          isoDate: "2021-08-13T00:06:05.000Z",
          link: "https://www.wowhead.com/news=323766/more-corporate-sponsors-abandon-the-overwatch-league-ibm-and-kellogg-company",
          pubDate: "Thu, 12 Aug 2021 19:06:05 -0500",
          title: "More Corporate Sponsors Abandon the Overwatch League - IBM and Kellogg Company Pull Support"
        }

  """
  def news()

  def news() do
    ~s(news)
    |> send_get([], limit: 1)
    |> List.first()
  end

  @doc """
  Returns the latest `num_of_articles` of World of Wacraft news articles from [Wowhead](https://www.wowhead.com/).

  ## Examples

      iex> Elexus.news(2)
      [
        %{
          categories: ["Blizzard"],
          content: "Two more corporate sponsors have removed their support from the Overwatch League in the wake of widespread allegations of sexual harassment and a discrimination lawsuit brought forth by the California Department of Fair Employment and Housing against Activision Blizzard. We previously saw T-Mobile and State Farm insurance reevaluating their partnerships, but now esports.gg has reported IBM and Kellogg's Cheez-It Grooves and Pringles Wavy withdrawing their support as well.",
          guid: "https://www.wowhead.com/news=323766",
          isoDate: "2021-08-13T00:06:05.000Z",
          link: "https://www.wowhead.com/news=323766/more-corporate-sponsors-abandon-the-overwatch-league-ibm-and-kellogg-company",
          pubDate: "Thu, 12 Aug 2021 19:06:05 -0500",
          title: "More Corporate Sponsors Abandon the Overwatch League - IBM and Kellogg Company Pull Support"
        },
        %{
          categories: ["TBC"],
          content: "An update to the Burning Crusade Classic Public Test Realm just went live, implementing the Arena Reward Cutoffs and an interesting change to the whistle emote sound.\\nArena Reward Cutoffs\\nBehind the Arena Battlemasters in Shattrath is an &quot;Arena Bulletin Board&quot; that players can interact with. This billboard will display information regarding how to qualify for Arena Season rewards, what the percentage cutoffs are, and a current Rating cutoff for those rewards.",
          guid: "https://www.wowhead.com/news=323762",
          isoDate: "2021-08-11T22:43:00.000Z",
          link: "https://www.wowhead.com/news=323762/updates-on-burning-crusade-classic-ptr-arena-reward-cutoffs-and-whistle-emote",
          pubDate: "Wed, 11 Aug 2021 17:43:00 -0500",
          title: "Updates on Burning Crusade Classic PTR - Arena Reward Cutoffs and Whistle Emote Change"
        }
      ]


  """
  def news(num_of_articles)

  def news(num_of_articles) do
    ~s(news)
    |> send_get([], limit: num_of_articles)
  end

  @doc """
  Fuzzy item search by `query`. Note the misspelled item name in the example.

  ## Examples

      iex>Elexus.search("Ironfow", 1, 0.8)
      [
        %{
          itemId: 11684,
          name: "Ironfoe",
          uniqueName: "ironfoe",
          imgUrl: "https://wow.zamimg.com/images/wow/icons/large/spell_frost_frostbrand.jpg"
        }
      ]

  """

  def search(query, limit \\ 10, threshold \\ 0.4) do
    ~s(search)
    |> send_get([], query: query, limit: limit, threshold: threshold)
  end

  @doc """
  Fuzzy item suggestions by `query` using `String.starts_with?/2`. Use for autocomplete, etc

  ## Examples

      iex> Elexus.suggestions("devi", 3)
      [
        %{
          itemId: 6522,
          name: "Deviate Fish",
          uniqueName: "deviate-fish",
          imgUrl: "https://wow.zamimg.com/images/wow/icons/large/inv_misc_monsterhead_01.jpg",
          type: "Consumable"
        },
        %{
          itemId: 6443,
          name: "Deviate Hide",
          uniqueName: "deviate-hide",
          imgUrl: "https://wow.zamimg.com/images/wow/icons/large/inv_misc_pelt_wolf_ruin_03.jpg",
          type: "Quest"
        },
        %{
          itemId: 6470,
          name: "Deviate Scale",
          uniqueName: "deviate-scale",
          imgUrl: "https://wow.zamimg.com/images/wow/icons/large/inv_misc_monsterscales_02.jpg",
          type: "Trade Goods"
        }
      ]

  """

  def suggestions(query, limit \\ 3) do
    ~s(search/suggestions)
    |> send_get([], query: query, limit: limit)
  end

  ########
  # Private
  ########

  defp bangify({:ok, body}), do: body
  defp bangify({:error, reason}), do: raise(reason)

  defp send_get(endpoint, options \\ [], params \\ [])

  defp send_get(endpoint, options, params) do
    Elexus.Base.get(endpoint, options, params: params)
    |> return_get()
  end

  defp return_get({:ok, %{body: body, status_code: 200}}), do: body

  defp return_get({:ok, %HTTPoison.Response{body: %{reason: reason}, status_code: 404}}),
    do: {:error, reason}
end
