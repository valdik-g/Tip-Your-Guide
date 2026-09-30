# Seed data for the sandbox. Not FactoryBot on purpose:
# https://thoughtbot.com/blog/factory_bot-for-seed-data

RED = "\e[31m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
RESET = "\e[0m"

def print_step_start(message, color: YELLOW)
  printf "#{color}%-35s#{RESET}", message
  $stdout.flush
end

def print_step_end(message = "Done!", color: GREEN)
  printf "#{color}#{message}#{RESET}\n"
end

print_step_start("Clearing existing data...", color: RED)
ActiveRecord::Base.connection.tables.each do |table|
  next if table == "schema_migrations" || table == "ar_internal_metadata"

  ActiveRecord::Base.connection.execute("TRUNCATE #{table} CASCADE")
rescue => e
  printf "Error truncating #{table}: #{e.message}"
  model = table.classify.safe_constantize
  model&.destroy_all
end
print_step_end

# == Users ==
print_step_start("Creating users...")
admin = User.create!(
  email: "admin@example.com",
  password: "password",
  full_name: "Admin Bernard",
  country: "DE",
  city: "Berlin",
  bio: "Runs the back office. Not a chef.",
  roles: [Role.admin]
)

guide_role = Role.guide

clara = User.create!(
  email: "clara@example.com",
  password: "password",
  full_name: "Clara Wenzel",
  country: "FR",
  city: "Paris",
  bio: "Chef, ran the pass at a bistrot in the 11th for six years. Writes about produce, " \
       "bread and the places she actually eats on her nights off.",
  roles: [guide_role]
)

tomasz = User.create!(
  email: "tomasz@example.com",
  password: "password",
  full_name: "Tomasz Rey",
  country: "PL",
  city: "Warsaw",
  bio: "Sommelier turned importer. Natural wine, mostly Central Europe. Opinionated about " \
       "temperature and glassware, relaxed about everything else.",
  roles: [guide_role]
)
print_step_end

# == Payment infos (existing one-off Stripe products) ==
print_step_start("Creating payment infos...")
clara_collections = PaymentInfo.create!(
  user: clara,
  stripe_product_id: "prod_sandbox_collection_clara",
  charge_type: :collection_purchase
)
PaymentInfo.create!(
  user: clara,
  stripe_product_id: "prod_sandbox_donation_clara",
  charge_type: :donation_purchase
)
tomasz_collections = PaymentInfo.create!(
  user: tomasz,
  stripe_product_id: "prod_sandbox_collection_tomasz",
  charge_type: :collection_purchase
)
print_step_end

# == Places ==
print_step_start("Creating places...")
places = {
  septime_cave: {title: "La Cave de Septime", description: "Wine bar, 11th. Go early, eat at the bar.", url: "www.septime-charonne.fr", user: clara},
  du_pain: {title: "Du Pain et des Idées", description: "Bakery, 10th. The pain des amis is the point.", url: "www.dupainetdesidees.com", user: clara},
  clamato: {title: "Clamato", description: "Seafood, no reservations. Queue at 18:45 or don't bother.", url: "www.clamato-charonne.fr", user: clara},
  marche_aligre: {title: "Marché d'Aligre", description: "Market, 12th. Sunday morning, before ten.", url: "www.marchedaligre.free.fr", user: clara},
  wino: {title: "Wino Wino", description: "Natural wine shop and bar, Warsaw. Ask what just landed.", url: "www.winowino.pl", user: tomasz},
  charlotte: {title: "Charlotte Menora", description: "All-day bakery on Plac Grzybowski.", url: "www.bistrocharlotte.pl", user: tomasz},
  rebel_rebel: {title: "Rebel Rebel", description: "Berlin. Tiny, loud, excellent list.", url: "www.rebelrebel.de", user: tomasz},
  ora: {title: "Ora", description: "Former pharmacy, Kreuzberg. Come for the room, stay for the list.", url: "www.ora-berlin.de", user: tomasz}
}.transform_values { |attrs| Place.create!(**attrs) }
print_step_end

# == Collections (paid + public), the existing one-off purchase flow ==
print_step_start("Creating collections...")
paris_food = Collection.create!(
  title: "Paris: where I eat on a Monday",
  description: "Most of the good rooms are closed on Mondays. These are not.",
  places: [places[:septime_cave], places[:clamato], places[:du_pain]],
  user: clara,
  status: :paid
)
Collection::Price.create!(
  collection: paris_food,
  price: 1000,
  currency: :eur,
  payment_info: clara_collections,
  stripe_id: "price_sandbox_paris_food"
)

wine_walk = Collection.create!(
  title: "A natural wine walk, Warsaw to Berlin",
  description: "Eight bottles, four rooms, two cities. In order.",
  places: [places[:wino], places[:rebel_rebel], places[:ora]],
  user: tomasz,
  status: :paid
)
Collection::Price.create!(
  collection: wine_walk,
  price: 700,
  currency: :eur,
  payment_info: tomasz_collections,
  stripe_id: "price_sandbox_wine_walk"
)

Collection.create!(
  title: "Mornings",
  description: "Bakeries and markets. Free, because everyone should have these.",
  places: [places[:du_pain], places[:marche_aligre], places[:charlotte]],
  user: clara,
  status: :public
)
print_step_end

# == Articles ==
# These are the material for the paywall task. Each one has an open half
# (observation, context, what to look for) and a half that carries the
# precise, reproducible detail. How you split them is your decision.
print_step_start("Creating articles...")

def article(user:, title:, slug:, locale:, description:, keywords:, body:, premium_title: nil, premium_content: nil)
  BlogPost.create!(
    title: title,
    slug: slug,
    locale: locale,
    content: body,
    author_name: user.full_name,
    published: true,
    published_at: rand(1..60).days.ago,
    meta_description: description,
    meta_keywords: keywords,
    blog_post_premium_attributes: {
      premium_title: premium_title,
      premium_content: premium_content
    }
  )
end

article(
  user: clara,
  title: "Focaccia: what the dough is telling you",
  slug: "focaccia-what-the-dough-is-telling-you",
  locale: :en,
  description: "How to read focaccia dough by hand, and the numbers that make it repeatable.",
  keywords: "focaccia, bread, hydration, dough, baking",
  body: <<~MD
    Most focaccia recipes fail you at the same moment: they give you a hydration
    number and no way to tell whether your flour agrees with it.

    ## What you are looking for

    After the first fold the dough should hold a fold for about four seconds
    before it starts to slump. Not longer — longer means the gluten is tight and
    the crumb will come out closed and bready. Not shorter, or it will spread flat
    in the tin and fry rather than bake.

    The surface tells you more than the clock does. When it goes from matte to
    faintly glossy, the flour has finished drinking. Some flours get there in
    forty minutes, some take two hours. This is why timing a recipe never works
    across kitchens.

    Press two fingers in. If the dimple fills back halfway and stops, you are
    ready. If it springs all the way back, wait.
  MD
  premium_title: "Full recepie with exact measurements",
  premium_content: <<~MD
    ## The numbers

    For one 30×40cm tin:

    - Strong white flour, 12–13% protein: 1000 g
    - Water, 32°C: 820 g (82%)
    - Fine sea salt: 22 g
    - Fresh yeast: 8 g, or 3 g instant
    - Olive oil, in the dough: 40 g
    - Olive oil, in the tin: 30 g

    Autolyse flour and 750 g of the water for 45 minutes. Add yeast, then salt,
    then the remaining 70 g of water in three additions, waiting for each to be
    absorbed. Oil last.

    Four coil folds, 30 minutes apart. Bulk at 24°C until it has risen by 70%,
    roughly three hours. Into the oiled tin, rest 45 minutes, dimple with wet
    fingers, brine on top (20 g water, 4 g salt).

    Bake at 250°C for 12 minutes, then 220°C for 10–12 more. Out of the tin
    immediately, onto a rack, or the bottom steams and goes soft.
  MD
)

article(
  user: clara,
  title: "Monday in Paris, and why the good rooms are shut",
  slug: "monday-in-paris",
  locale: :en,
  description: "The economics behind Paris closing days, and where the industry eats instead.",
  keywords: "paris, monday, restaurants, industry, dining",
  body: <<~MD,
    Ask a cook in Paris what day they eat well and they will not say Saturday.

    ## Why Monday is closed

    Most independent kitchens run a six-day week with one full closure, and that
    closure is almost always Sunday and Monday together, because the produce
    calendar makes it cheap. Rungis is quiet on Sunday. The good fish comes
    Tuesday. Holding a Monday service means paying Friday's staff cost for
    Tuesday's stock, minus a day of freshness.

    So the rooms that do open on Monday tend to be one of two things: places with
    a shorter, cheaper menu built for it, or places good enough to ignore the
    calendar entirely.

    ## Where to actually go

    The full list, with what to order at each and the hour to arrive, is in the
    guide. The short version: three in the 11th, one in the 10th, and one that
    only works if you are two people and willing to eat standing.
  MD
)

article(
  user: tomasz,
  title: "Reading a natural wine back label",
  slug: "reading-a-natural-wine-back-label",
  locale: :en,
  description: "What certifications, importer marks and sulphite statements actually tell you.",
  keywords: "natural wine, labels, sulphites, importers",
  body: <<~MD
    A back label is mostly marketing, but four things on it are load-bearing.

    ## The importer mark

    In practice the importer tells you more than the producer does. A small
    importer with forty growers has tasted every one of them and staked a
    business on the choice. That is a stronger filter than any certification.

    ## Sulphites

    "Contains sulphites" is a legal threshold, not a style statement — it appears
    at 10 mg/l, which is roughly what fermentation produces on its own. It tells
    you almost nothing. The number that matters is total SO₂, and it is almost
    never printed.

    ## What to actually look for

    The specific importers worth trusting by region, the certification bodies that
    mean something versus the ones that are self-declared, and the phrasing that
    signals a wine was corrected in the cellar — that is the rest of this piece.
  MD
)

article(
  user: tomasz,
  title: "Serving temperature is the whole argument",
  slug: "serving-temperature-is-the-whole-argument",
  locale: :en,
  description: "Why most natural wine is served too warm, and the ranges that fix it.",
  keywords: "wine, serving temperature, natural wine, cellar",
  body: <<~MD
    Nearly every complaint about natural wine — volatile, sweet, farmyard — is a
    complaint about temperature.

    ## The mechanism

    Volatile acidity and reduction both scale with temperature. Four degrees is
    the difference between a wine reading as bright and reading as vinegary. Most
    rooms serve reds at ambient, and ambient in a full dining room in July is 26°C.

    A cellar in a Burgundian farmhouse in 1960 was 13°C. "Room temperature" is a
    measurement from a room that no longer exists.

    ## The ranges

    Per style, with the fridge timings that get you there from a warm shelf, and
    what to do when the bottle arrives wrong and you do not want to make a scene.
  MD
)

article(
  user: clara,
  title: "Фокачча: что вам говорит тесто",
  slug: "focaccia-chto-govorit-testo",
  locale: :ru,
  description: "Как читать тесто для фокаччи руками и какие цифры делают результат повторяемым.",
  keywords: "фокачча, хлеб, тесто, гидратация, выпечка",
  body: <<~MD
    Большинство рецептов фокаччи подводят в один и тот же момент: дают процент
    гидратации и никакого способа понять, согласна ли с ним ваша мука.

    ## На что смотреть

    После первого складывания тесто должно держать складку примерно четыре
    секунды, прежде чем начнёт оседать. Не дольше — дольше значит, что клейковина
    затянута, и мякиш выйдет плотным.

    Поверхность скажет больше, чем таймер. Когда матовое становится чуть
    глянцевым — мука напилась. Одной муке нужно сорок минут, другой два часа.
    Поэтому рецепт по времени не переносится из кухни в кухню.

    ## Цифры

    Точная граммовка, температура воды, график складываний и режим духовки —
    дальше.
  MD
)
print_step_end

# == Payments (history for the existing one-off flow) ==
print_step_start("Creating payments...")
5.times do |i|
  payment = Payment.create!(
    user: clara,
    amount: [500, 1000, 2000].sample,
    currency: :eur,
    payment_info: clara_collections,
    payer_email: "reader_#{i}@example.com",
    payer_name: "Reader #{i}",
    stripe_id: "pi_sandbox_#{i}"
  )
  Payment::Status.create!(payment: payment, kind: :paid, last: true)
end
print_step_end

# == Waitlist ==
print_step_start("Creating waitlist entries...")
Waitlist.create!(email: "wants-in@example.com", city: "Lisbon", country: "PT")
print_step_end

# == Subscriptions ==
print_step_start("Creating active subscription for admin...")
Subscription.create!(
  user: admin,
  status: 'active', 
  cancel_at_period_end: false, 
  current_period_end: DateTime.now + 1.month,
  stripe_subscription_id: 'sandbox-stripe-id',
)
print_step_end

print_step_end("Finished seeding the database!", color: GREEN)
print_step_end("Admin:  #{admin.email} : password", color: RED)
print_step_end("Author: #{clara.email} : password", color: RED)
print_step_end("Author: #{tomasz.email} : password", color: RED)
