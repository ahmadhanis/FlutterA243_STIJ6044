-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 12, 2025 at 04:28 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mytodolistdb`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_todos`
--

CREATE TABLE `tbl_todos` (
  `todo_id` int(11) NOT NULL,
  `user_id` varchar(5) NOT NULL,
  `todo_title` varchar(200) NOT NULL,
  `todo_desc` varchar(500) NOT NULL,
  `todo_category` varchar(20) NOT NULL,
  `todo_date` datetime(6) NOT NULL,
  `todo_priority` varchar(20) NOT NULL,
  `todo_completed` varchar(20) NOT NULL,
  `todo_reminder` varchar(20) NOT NULL,
  `date_create` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_todos`
--

INSERT INTO `tbl_todos` (`todo_id`, `user_id`, `todo_title`, `todo_desc`, `todo_category`, `todo_date`, `todo_priority`, `todo_completed`, `todo_reminder`, `date_create`) VALUES
(1, '5', 'Shopping with family', 'Lotus jitra', 'Shopping', '2025-07-11 11:45:00.000000', 'Important', 'false', 'false', '2025-07-05 10:00:30.191856'),
(2, '5', 'Master class', 'UUM SOC', 'Work', '2025-07-12 09:00:00.000000', 'Important', 'false', 'true', '2025-07-05 10:05:14.893371'),
(3, '5', 'Mobile Training', 'UUM Makerspace SOC', 'Work', '2025-07-15 09:00:00.000000', 'Important', 'true', 'true', '2025-07-05 10:06:05.300270'),
(4, '5', 'Meeting', 'JKPA', 'Work', '2025-07-19 14:30:00.000000', 'Important', 'false', 'false', '2025-07-12 07:28:44.122290'),
(5, '5', 'Pick up parcel', 'J&T near Taman Suria', 'Personal', '2025-07-12 16:00:00.000000', 'Normal', 'false', 'true', '2025-07-06 09:12:33.000000'),
(6, '5', 'Project discussion', 'KTARGO! app backend updates', 'Work', '2025-07-13 10:00:00.000000', 'Important', 'false', 'true', '2025-07-06 10:45:00.000000'),
(7, '5', 'Doctor appointment', 'Annual checkup at Klinik Kesihatan', 'Health', '2025-07-14 09:00:00.000000', 'Normal', 'false', 'true', '2025-07-06 11:00:00.000000'),
(8, '5', 'Grocery shopping', 'Tesco for weekly groceries', 'Shopping', '2025-07-14 17:00:00.000000', 'Normal', 'false', 'false', '2025-07-07 08:00:00.000000'),
(9, '5', 'Online class', 'Flutter intermediate module', 'Study', '2025-07-15 20:00:00.000000', 'Important', 'false', 'true', '2025-07-07 09:10:00.000000'),
(10, '5', 'Pay electricity bill', 'Via TNB portal', 'Personal', '2025-07-16 13:00:00.000000', 'Important', 'false', 'false', '2025-07-07 10:00:00.000000'),
(11, '5', 'Finish report', 'Entrepreneurship report final edits', 'Work', '2025-07-16 21:00:00.000000', 'Important', 'false', 'true', '2025-07-07 11:30:00.000000'),
(12, '5', 'Clean room', 'Weekend cleanup and laundry', 'Personal', '2025-07-17 10:30:00.000000', 'Normal', 'false', 'false', '2025-07-08 09:00:00.000000'),
(13, '5', 'Call supplier', 'Discuss mushroom packaging update', 'Work', '2025-07-17 15:00:00.000000', 'Important', 'false', 'true', '2025-07-08 09:20:00.000000'),
(14, '5', 'Attend workshop', 'Arduino sensors workshop (2hr)', 'Learning', '2025-07-18 14:00:00.000000', 'Important', 'false', 'true', '2025-07-08 10:00:00.000000'),
(15, '5', 'Jogging', 'Evening jog at Taman Rekreasi', 'Health', '2025-07-18 18:30:00.000000', 'Normal', 'false', 'false', '2025-07-08 11:00:00.000000'),
(16, '5', 'Send email', 'Email proposal to Dr. Zaidatun', 'Work', '2025-07-19 09:00:00.000000', 'Important', 'false', 'true', '2025-07-08 13:30:00.000000'),
(17, '5', 'Birthday gift', 'Buy present for Harisah', 'Personal', '2025-07-19 16:00:00.000000', 'Normal', 'false', 'false', '2025-07-09 08:10:00.000000'),
(18, '5', 'MathWizard testing', 'UI bug fixes for version 1.2', 'Work', '2025-07-20 14:00:00.000000', 'Important', 'false', 'true', '2025-07-09 09:00:00.000000'),
(19, '5', 'Visit grandma', 'Weekend trip to Alor Setar', 'Family', '2025-07-20 10:00:00.000000', 'Normal', 'false', 'false', '2025-07-09 10:00:00.000000'),
(20, '5', 'Upload video', 'Final cut for e-Inovasi contest', 'Work', '2025-07-21 13:00:00.000000', 'Important', 'false', 'true', '2025-07-09 11:00:00.000000'),
(21, '5', 'Water plants', 'Daily watering routine', 'Personal', '2025-07-12 07:30:00.000000', 'Normal', 'false', 'false', '2025-07-09 12:30:00.000000'),
(22, '5', 'Buy printer ink', 'Cartridge for Epson L3250', 'Shopping', '2025-07-13 15:00:00.000000', 'Normal', 'false', 'false', '2025-07-09 14:00:00.000000'),
(23, '5', 'Plan next workshop', 'Arduino + sensors for STEM', 'Work', '2025-07-22 10:00:00.000000', 'Important', 'false', 'true', '2025-07-09 15:00:00.000000'),
(24, '5', 'Laundry day', 'Wash and fold clothes', 'Personal', '2025-07-21 08:00:00.000000', 'Normal', 'false', 'false', '2025-07-09 16:00:00.000000');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(3) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `user_password` varchar(40) NOT NULL,
  `user_datereg` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`user_id`, `user_email`, `user_password`, `user_datereg`) VALUES
(5, 'slumberjer@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '2025-06-21 09:34:24.095606');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_todos`
--
ALTER TABLE `tbl_todos`
  ADD PRIMARY KEY (`todo_id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_todos`
--
ALTER TABLE `tbl_todos`
  MODIFY `todo_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
