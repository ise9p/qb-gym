CREATE TABLE IF NOT EXISTS gym_memberships (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    months INT NOT NULL,
    price INT NOT NULL,
    expiry BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS `gym_funds` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `amount` INT NOT NULL DEFAULT 0
);

INSERT INTO `gym_funds` (`id`, `amount`) VALUES (1, 0);
