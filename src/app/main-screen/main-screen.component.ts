import { Component } from '@angular/core';
import { NoteCardComponent } from '../note-card/note-card.component';
import { NavbarComponent } from '../navbar/navbar.component';
import { MainNavbarComponent } from '../main-navbar/main-navbar.component';

@Component({
  selector: 'app-main-screen',
  standalone: true,
  imports: [NoteCardComponent, MainNavbarComponent],
  templateUrl: './main-screen.component.html',
  styleUrl: './main-screen.component.scss',
})
export class MainScreenComponent {
  cards = [
    {
      text: 'Lorem, ipsum dolor sit amet consectetur adipisicing elit. Incidunt, beatae voluptatibus. Officia at voluptates, facere animi minima, voluptatum explicabo molestiae repellat expedita eius libero quaerat aut reprehenderit nisi autem assumenda!',
    },
    { text: 'asdasdasdsadasdasd' },
    {
      text: 'Lorem, ipsum dolor sit amet consectetur adipisicing elit. Incidunt, beatae voluptatibus. Officia at voluptates, facere animi minima, voluptatum explicabo molestiae repellat expedita eius libero quaerat aut reprehenderit nisi autem assumenda!',
    },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
  ];
}
