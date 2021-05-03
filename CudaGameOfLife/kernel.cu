
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <windows.h>
#include <sstream>
#include "Game.h"
#include <chrono>
#include <iostream>

#define I 25
#define J 25

bool cells[I][J];
__device__ bool dev_cells[I][J];

void fillArray(std::vector<std::vector<bool>> cellsVector) 
{
    for (int i = 0; i < I; i++) {
        int j = 0;
        for (
            auto it = cellsVector[i].begin();
            it != cellsVector[i].end(); it++)
        {
            cells[i][j] = *it == 1;
            ++j;
        }
        std::cout << std::endl;
    }
}

void playCpu(Game &game) 
{
    auto start = std::chrono::high_resolution_clock::now();
    game.PlayGame();
    auto stop = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start).count();
    auto durationMilisec = duration / (double)1000000;
    std::cout << "CPU running time on "<< I << "x" << J << " board: "  <<durationMilisec << " s" <<std::endl;
}

__global__ void playGpu()
{
    __shared__ bool shr_cells[I][J];
    int idx = blockDim.x * blockIdx.x + threadIdx.x;
    auto fakeJ = 0;
    auto fakeI = 0;
    if (idx >= J) {
        fakeI = idx / J;
        fakeJ = idx - ( fakeI * J );
    }
    else {
        fakeJ = idx;
    }
    shr_cells[fakeI][fakeJ] = dev_cells[fakeI][fakeJ];
    __syncthreads();

    auto count = 0;

    if (fakeI > 0 && fakeJ > 0) {
        if (shr_cells[fakeI - 1][fakeJ - 1]) ++count;
    }
    // top
    if (fakeI > 0) {
        if (shr_cells[fakeI - 1][fakeJ]) ++count;
    }
    // top right
    if (fakeI > 0 && fakeJ < J - 1) {
        if (shr_cells[fakeI - 1][fakeJ + 1]) ++count;
    }
    // right
    if (fakeJ < J - 1) {
        if (shr_cells[fakeI][fakeJ + 1]) ++count;
    }
    // bottom right
    if (fakeI < I - 1 && fakeJ < J - 1) {
        if (shr_cells[fakeI + 1][fakeJ + 1]) ++count;
    }
    // bottom
    if (fakeI < I - 1) {
        if (shr_cells[fakeI + 1][fakeJ]) ++count;
    }
    // bottom left
    if (fakeI < I - 1 && fakeJ > 0) {
        if (shr_cells[fakeI + 1][fakeJ - 1]) ++count;
    }
    // left
    if (fakeJ > 0) {
        if (shr_cells[fakeI][fakeJ - 1]) ++count;
    }

    __syncthreads();

    if (shr_cells[fakeI][fakeJ] == true)
    {
        if (!(count == 2 || count == 3))
        {
        shr_cells[fakeI][fakeJ] = false;
        }
    }
    else
    {
        if (count == 3)
        {
        shr_cells[fakeI][fakeJ] = true;
        }
    }
    dev_cells[fakeI][fakeJ] = shr_cells[fakeI][fakeJ];

    __syncthreads();
}

void displayBoard()
{
    for (int i = 0; i < I; i++) {
        for (int j = 0; j < J; j++)
        {
            auto displayVariable = cells[i][j] == 1 ? "+" : "-";
            //auto displayVariable = *it == 1 ? getNeighboursAlive(i, j) : 0;
            //std::cout << displayVariable;
            std::cout << displayVariable << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

int main()
{
    // sor, oszlop
    auto game1 = Game(I, J);
    auto gameTable = game1.m_Cells;
    //playCpu(game1);
    fillArray(gameTable);
    displayBoard();
    
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int blockNumber = 1;
    int threadNumber = I*J;
    if (threadNumber > 1024)
    {
        blockNumber = threadNumber % 1024 == 0 ? threadNumber / 1024 : threadNumber / 1024 + 1;
        threadNumber = 1024;
    }


    cudaEventRecord(start);
    for (size_t i = 0; i < 100; i++)
    {
        cudaMemcpyToSymbol(dev_cells, cells, I * J * sizeof(bool));
        playGpu << < blockNumber, threadNumber >> > ();
        cudaMemcpyFromSymbol(cells, dev_cells, I * J * sizeof(bool));
    }
    
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    std::cout << "GPU running time: " << milliseconds << " ms" << std::endl;
    displayBoard();

    return 0;
}