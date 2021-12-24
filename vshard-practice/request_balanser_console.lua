--Запросы с балансировкой
--Первый запрос будет выполнен на самой ближайшей ноде
--Для Московского шарда в зоне Moscow
--Для Питерского шарда в зоне Spb Area, так как она ближе всего к московскому роутеру
-- vshard.router.callbro(1, 'print', {'Request 1 processor here!'})
-- vshard.router.callbro(1, 'print', {'Request 1 processor here!'})
-- vshard.router.callbro(2, 'print', {'Request 2 processor here!'})
-- vshard.router.callbro(2, 'print', {'Request 2 processor here!'})

-- vshard.router.callrw(1, 'print', {'Request 1 processor here!'}) -- Отправляет запросы только на мастер
-- vshard.router.callro(1, 'print', {'Request 1 processor here!'}) -- Отправляет запрос на мастер, если мастер не доступен идет на реплику
-- vshard.router.callbro(2, 'print', {'Request 2 processor here!'}) -- Выбирает () и балансирует преимущественно м/у мастерами
-- vshard.router.callbre(2, 'print', {'Request 2 processor here!'}) -- Выбирает () и балансирует преимущественно м/у репликами

