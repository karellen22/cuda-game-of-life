#include "Game.h"
#include <iostream>
#include <random>

Game::Game(const int& i, const int& j)
	: m_I(i)
	, m_J(j)
{
	m_Alive = 0;
	m_Cells = std::vector<std::vector<bool>>(m_I, std::vector<bool>(m_J, false));
	fillBoard();
}

void Game::PlayGame()
{
	auto counter = 0;
	//std::cout << "Starting board:" << std::endl;
	//std::cout << "____________________________" << std::endl;
	//displayBoard();
	while (counter < 1000 && isAlive()) {
		killCells();
		//displayBoard();
		++counter;
		//std::cout << "Round: " << counter << std::endl;
	}
	//std::cout << "Finishing board:" << std::endl;
	//displayBoard();
	std::cout << "Number of rounds: " << counter << std::endl;
	//std::cout << "____________________________" << std::endl;

}

void Game::displayBoard()
{
	for (int i = 0; i < m_I; i++) {
		int j = 0;
		for (
			auto it = m_Cells[i].begin();
			it != m_Cells[i].end(); it++)
		{
			auto displayVariable = *it == 1 ? "+" : "-";
			//auto displayVariable = *it == 1 ? getNeighboursAlive(i, j) : 0;
			//std::cout << displayVariable;
			std::cout << displayVariable << " ";
			++j;
		}
		std::cout << std::endl;
	}
}


bool Game::isAlive()
{
	return m_Alive > 0;
}

int Game::getNeighboursAlive(int indexI, int indexJ)
{
	auto count = 0;
	// top left
	if (indexI > 0 && indexJ > 0) {
		if (m_Cells[indexI - 1][indexJ - 1]) ++count;
	}
	// top
	if (indexI > 0) {
		if (m_Cells[indexI - 1][indexJ]) ++count;
	}
	// top right
	if (indexI > 0 && indexJ < m_J - 1) {
		if (m_Cells[indexI - 1][indexJ + 1]) ++count;
	}
	// right
	if (indexJ < m_J - 1) {
		if (m_Cells[indexI][indexJ + 1]) ++count;
	}
	// bottom right
	if (indexI < m_I - 1 && indexJ < m_J - 1) {
		if (m_Cells[indexI + 1][indexJ + 1]) ++count;
	}
	// bottom
	if (indexI < m_I - 1) {
		if (m_Cells[indexI + 1][indexJ]) ++count;
	}
	// bottom left
	if (indexI < m_I - 1 && indexJ > 0) {
		if (m_Cells[indexI + 1][indexJ - 1]) ++count;
	}
	// left
	if (indexJ > 0) {
		if (m_Cells[indexI][indexJ - 1]) ++count;
	}
	return count;
}

void Game::fillBoard()
{
	std::random_device rD;
	std::default_random_engine rE(rD());
	std::uniform_int_distribution<int> distribution(0, 1);

	for (size_t i = 0; i < m_I; i++)
	{
		for (size_t j = 0; j < m_J; j++)
		{
			auto x = distribution(rE);
			if (x == 1) {
				m_Cells[i][j] = true;
				++m_Alive;
			}
			
		}
	}
}

void Game::killCells()
{
	std::vector<std::vector<int>> markedForKill;
	std::vector<std::vector<int>> markedForResurrect;
	for (int i = 0; i < m_I; i++) {
		int j = 0;
		for (
			auto it = m_Cells[i].begin();
			it != m_Cells[i].end(); it++)
		{
			auto alive = getNeighboursAlive(i, j);
			if (*it == 1)
			{
				if (!(alive == 2 || alive == 3)) 
				{
					std::vector<int> coords;
					coords.push_back(i);
					coords.push_back(j);
					markedForKill.push_back(coords);
				}
			}
			else
			{
				if (alive == 3)
				{
					std::vector<int> coords;
					coords.push_back(i);
					coords.push_back(j);
					markedForResurrect.push_back(coords);
				}
			}
			++j;
		}
	}

	for (int i = 0; i < markedForKill.size(); i++) {
		auto tempI = markedForKill[i][0];
		auto tempJ = markedForKill[i][1];
		m_Cells[tempI][tempJ] = !m_Cells[tempI][tempJ];	
		--m_Alive;
	}

	for (int i = 0; i < markedForResurrect.size(); i++) {
		auto tempI = markedForResurrect[i][0];
		auto tempJ = markedForResurrect[i][1];
		m_Cells[tempI][tempJ] = !m_Cells[tempI][tempJ];
		++m_Alive;
	}

}
