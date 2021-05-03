#pragma once
#include <vector>

class Game
{
public: 
	Game(const int& i, const int& j);

	void PlayGame();
	std::vector<std::vector<bool>> m_Cells;
private:
	bool isAlive();
	int getNeighboursAlive(int indexI, int indexJ);
	void fillBoard();
	void killCells();
	void displayBoard();

	int m_I;
	int m_J;
	int m_Alive;
};

