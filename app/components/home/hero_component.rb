# frozen_string_literal: true

module Home
  class HeroComponent < ApplicationComponent
    attr_reader :total_places, :total_users, :total_payments

    def initialize(total_places:, total_users:, total_payments:)
      @total_places = total_places
      @total_users = total_users
      @total_payments = total_payments
    end

    def places_count
      t("home.hero.hidden_gems", count: total_places)
    end

    def users_count
      t("home.hero.users_count", count: total_users)
    end

    def payments_count
      t("home.hero.payments_count", count: total_payments)
    end

    def description
      t("home.hero.description").split("\n").map { |line| "<span class='block'>#{line}</span>" }.join.html_safe
    end

    def header_image_url
      "https://images.unsplash.com/photo-1579033631786-12b00de12740?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80"
    end

    def users_count_badge
      content_tag(:div, class: "absolute top-10 md:top-20 md:-left-1 lg:-left-30 xl:-left-40 z-20 bg-white rounded-lg shadow-lg px-3 py-2 md:px-4 md:py-3 transform sm:rotate-0 md:rotate-2") do
        content_tag(:div, class: "flex items-center gap-2 md:gap-3") do
          safe_join([
            tag.svg(
              xmlns: "http://www.w3.org/2000/svg",
              class: "h-5 w-5 md:h-6 md:w-6 text-blue-600",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke: "currentColor"
            ) do
              tag.path(
                "stroke-linecap": "round",
                "stroke-linejoin": "round",
                "stroke-width": "2",
                d: "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
              )
            end,
            content_tag(:span, users_count, class: "text-sm font-medium")
          ])
        end
      end
    end

    def places_count_badge
      content_tag(:div, class: "absolute bottom-15 md:bottom-25 md:-left-1 lg:-left-30 xl:-left-40 z-20 bg-white rounded-lg shadow-lg px-3 py-2 md:px-4 md:py-3 transform -rotate-4 sm:rotate-0 md:-rotate-4") do
        content_tag(:div, class: "flex items-center gap-2 md:gap-3") do
          safe_join([
            tag.svg(
              xmlns: "http://www.w3.org/2000/svg",
              class: "h-5 w-5 md:h-6 md:w-6 text-blue-600",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke: "currentColor"
            ) do
              safe_join([
                tag.path(
                  "stroke-linecap": "round",
                  "stroke-linejoin": "round",
                  "stroke-width": "2",
                  d: "M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                ),
                tag.path(
                  "stroke-linecap": "round",
                  "stroke-linejoin": "round",
                  "stroke-width": "2",
                  d: "M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                )
              ])
            end,
            content_tag(:span, places_count, class: "text-sm font-medium")
          ])
        end
      end
    end

    def payments_count_badge
      content_tag(:div, class: "absolute top-35 sm:top-50 md:-left-1 lg:-left-30 xl:-left-40 z-20 bg-white rounded-lg shadow-lg px-3 py-2 md:px-4 md:py-3 transform rotate-3 sm:rotate-0 md:rotate-3") do
        content_tag(:div, class: "flex items-center gap-2 md:gap-3") do
          safe_join([
            tag.svg(
              xmlns: "http://www.w3.org/2000/svg",
              class: "h-6 w-6 text-blue-600",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke: "currentColor"
            ) do
              safe_join([
                tag.path(
                  "stroke-linecap": "round",
                  "stroke-linejoin": "round",
                  "stroke-width": "2",
                  d: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                )
              ])
            end,
            content_tag(:span, payments_count, class: "text-sm font-medium")
          ])
        end
      end
    end

    def join_waitlist_button
      tag.a(
        href: "#waitlist_email",
        onclick: "event.preventDefault(); document.getElementById('waitlist_email').scrollIntoView({behavior: 'smooth'});",
        title: "Join Waitlist",
        class: "hidden lg:inline-flex items-center justify-center px-5 py-2.5 text-base transition-all duration-200 hover:bg-black focus:bg-indigo-800 font-semibold text-white bg-indigo-600 rounded-lg",
        role: "button"
      ) do
        safe_join([
          render(Shared::IconComponent.new("heart", color: "white")),
          tag.span(t("home.hero.join_waitlist"), class: "ml-2 mb-0.5")
        ])
      end
    end

    def icon_link_path
      current_user.present? ? edit_admin_profile_path : new_session_path
    end

    def icon_label
      current_user.present? ? t("home.hero.edit_profile") : t("home.hero.sign_in")
    end
  end
end
