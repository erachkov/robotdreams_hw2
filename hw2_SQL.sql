-- 1    вывести количество фильмов в каждой категории, отсортировать по убыванию.

select cat.name,
       count(*) count_films
from category cat
join film_category fcat ON fcat.category_id = cat.category_id
join film f ON f.film_id = fcat.film_id
group by cat.name
order by 2 desc;

-- 2   вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

select * from (
    select a.first_name, a.last_name, count(*) rent_quantity
    from
      actor a
      join film_actor fa ON a.actor_id = fa.actor_id
      join film f ON f.film_id = fa.film_id
      join inventory i ON i.film_id = f.film_id
      join rental r on r.inventory_id = i.inventory_id
    group by a.first_name, a.last_name
    order by 3 desc
    ) sub limit 10;


-- 3    вывести категорию фильмов, на которую потратили больше всего денег.

select cat.name,
       sum(p.amount) film_amount
from category cat
join film_category fcat ON fcat.category_id = cat.category_id
join film f ON f.film_id = fcat.film_id
join inventory i ON i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by cat.name
order by 2 desc;

--  4   вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

select f.title from
    film f
where not exists
    (select 1 from inventory i where i.film_id = f.film_id);

-- 5    вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех..
select * from (
select top.first_name, top.last_name, top.film_count from (
select a.first_name, a.last_name,  count(*) film_count
    from
      actor a
      join film_actor fa ON a.actor_id = fa.actor_id
      join film f ON f.film_id = fa.film_id
      join film_category fcat on f.film_id = fcat.film_id
      join category cat ON fcat.category_id = cat.category_id
where
     cat.name = 'Children'
group by a.first_name, a.last_name
order by  3 desc) top limit 3) top3
union all
--Если у нескольких актеров одинаковое кол-во фильмов, вывести всех
select top.first_name, top.last_name, top.film_count from (
select a.first_name, a.last_name,  count(*) film_count
    from
      actor a
      join film_actor fa ON a.actor_id = fa.actor_id
      join film f ON f.film_id = fa.film_id
      join film_category fcat on f.film_id = fcat.film_id
      join category cat ON fcat.category_id = cat.category_id
where
     cat.name = 'Children'
group by a.first_name, a.last_name
order by  3 desc) top where top.film_count in (
select sub.film_count from (
select a.first_name, a.last_name,  count(*) film_count
    from
      actor a
      join film_actor fa ON a.actor_id = fa.actor_id
      join film f ON f.film_id = fa.film_id
      join film_category fcat on f.film_id = fcat.film_id
      join category cat ON fcat.category_id = cat.category_id
where
     cat.name = 'Children'
group by a.first_name, a.last_name
order by  3 desc) sub group by sub.film_count having  count(film_count) >1);


--  6  вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.

SELECT c.city,
       cy.country,
       cust.active,
       count(*)
FROM customer cust
         JOIN rental r ON r.customer_id = cust.customer_id
         JOIN inventory i ON r.inventory_id = i.inventory_id
         JOIN store s ON i.store_id = s.store_id
         JOIN address a ON s.address_id = a.address_id
         JOIN city c ON a.city_id = c.city_id
         JOIN country cy ON c.country_id = cy.country_id
GROUP BY cy.country, c.city, cust.active
ORDER BY cust.active, cy.country, c.city;

--  7   вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

select cat.name,
       c.city,
       sum(round(extract(epoch from (r.return_date) - (r.rental_date))/3600)) as sum_hours
from category cat
join film_category fcat ON fcat.category_id = cat.category_id
join film f ON f.film_id = fcat.film_id
join inventory i ON i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join customer cust on r.customer_id = cust.customer_id
JOIN address a ON cust.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
where city like 'a%' or city like '%-%'
group by cat.name, c.city having sum(round(extract(epoch from (r.return_date) - (r.rental_date))/3600)) >0
order by 3 desc;